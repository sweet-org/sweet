import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:sweet/extensions/item_modifier_ui_extension.dart';
import 'package:sweet/model/fitting/fitting_implant.dart';
import 'package:sweet/model/fitting/fitting_nanocore.dart';
import 'package:sweet/model/fitting/fitting_nanocore_affix.dart';
import 'package:sweet/model/fitting/fitting_rig_integrator.dart';
import 'package:sweet/model/implant/implant_handler.dart';
import 'package:sweet/model/items/eve_echoes_categories.dart';
import 'package:sweet/model/nihilus_space_modifier.dart';
import 'package:sweet/model/ship/ship_loadout_definition.dart';
import 'package:sweet/util/utility.dart';

import '../database/database_exports.dart';
import '../model/character/character.dart';
import '../model/character/learned_skill.dart';
import '../model/fitting/fitting.dart';
import '../model/fitting/fitting_drone.dart';
import '../model/fitting/fitting_item.dart';
import '../model/fitting/fitting_module.dart';
import '../model/fitting/fitting_patterns.dart';
import '../model/fitting/fitting_ship.dart';
import '../model/fitting/fitting_skill.dart';
import '../model/ship/capacitor_simulation_results.dart';
import '../model/ship/eve_echoes_attribute.dart';
import '../model/ship/module_state.dart';
import '../model/ship/ship_fitting_loadout.dart';
import '../model/ship/slot_type.dart';
import '../model/ship/weapon_type.dart';
import '../repository/item_repository.dart';
import '../repository/localisation_repository.dart';
import '../util/constants.dart';
import 'attribute_calculator_service.dart';
import 'capacitor_simulator.dart';

class FittingSimulator extends ChangeNotifier {
  static late FittingItem _characterItem;
  static late FittingPatterns fittingPatterns;

  static FittingPattern? _currentDamagePattern;

  FittingPattern get currentDamagePattern =>
      _currentDamagePattern ?? FittingPattern.uniform;

  set currentDamagePattern(FittingPattern newPattern) {
    _currentDamagePattern = newPattern;
    notifyListeners();
  }

  final FittingShip ship;
  final bool isDrone;
  final CapacitorSimulator capacitorSimulator;
  final ItemRepository _itemRepository;
  final AttributeCalculatorService _attributeCalculatorService;
  double _shieldPercentage = 0.25;

  double get currentShieldPercentage => _shieldPercentage;
  int? _totalImplantLevels;

  int get totalImplantLevels =>
      _totalImplantLevels ?? _pilot?.totalImplantLevels ?? 0;

  final Fitting _fitting;
  List<ImplantHandler?> _implants;

  Iterable<FittingModule> modules({required SlotType slotType}) =>
      _fitting[slotType] ?? [];

  String get name => loadout.name;

  void setName(String newName) {
    loadout.setName(newName);
    notifyListeners();
  }

  Character? _pilot;

  Character get pilot => _pilot ?? Character.empty;

  void setPilot(Character newPilot) {
    _pilot?.removeListener(_pilotListener);
    _pilot = newPilot;
    _pilot?.addListener(_pilotListener);
    _pilotListener();
  }

  void _pilotListener() {
    updateImplantLevels(notify: false);
    updateSkills(skills: pilot.learntSkills).then(
      (_) => notifyListeners(),
    );
  }

  ImplantHandler? get implantHandler =>
      _implants.whereNotNull().firstWhereOrNull((e) => !e.isPassive);

  ImplantFitting? get activeImplant => implantHandler?.fitting;

  List<ImplantFitting?> get implants => [
        ..._implants.map((e) => e?.fitting),
      ];

  int get passiveImplantCount =>
      _implants.whereNotNull().where((e) => e.isPassive).length;

  bool get hasActiveImplant => implantHandler != null;

  bool setImplant(ImplantHandler? implant, {int slot = 0}) {
    bool canFit = true;
    if (implant != null) {
      final oldIndex =
          _implants.indexWhere((e) => implant.fitting.id == e?.fitting.id);
      // Fitting the same implant multiple times is allowed to apply changes
      // Should however must be in the same slot

      if (!implant.isPassive) {
        final actIndex = _implants.indexWhere((e) => !(e?.isPassive ?? true));
        canFit = actIndex == -1 || actIndex == slot;
      } else {
        final impIndex = _implants
            .indexWhere((e) => e?.implant.itemId == implant.implant.itemId);
        canFit = impIndex == -1 || impIndex == slot;
      }
      if (oldIndex != -1) {
        if (oldIndex != slot) {
          print(
              "Can't fit the same implant multiple times (old slot: $oldIndex, new slot: $slot)");
          canFit = false;
        } else {
          canFit = true;
        }
      }
    }
    if (!canFit) return false;
    if (slot < _implants.length) {
      _implants[slot]?.removeListener(_implantListener);
      _implants[slot] = implant;
    } else {
      _implants.add(implant);
      slot = _implants.length - 1;
    }

    _implants[slot]?.addListener(_implantListener);
    if (_implants[slot] == null) {
      loadout.setImplant(null, slot);
    } else {
      loadout.setImplant(implant!.fitting.id, slot);
    }
    ensureFreeImplantSlots();
    _implantListener();
    return true;
  }

  void _implantListener() {
    _updateFitting();
  }

  void ensureFreeImplantSlots() {
    if (!_implants.any((e) => e == null)) {
      // There should be always an empty slot at the end
      _implants.add(null);
    } else {
      // Remove unused slots at the end (if there are more than 2)
      while (_implants.length > 1 &&
          _implants.last == null &&
          _implants[_implants.length - 2] == null) {
        _implants.removeLast();
      }
    }
  }

  int getImplantIndex(ImplantFitting fitting) {
    return _implants.indexWhere((element) => element?.fitting == fitting);
  }

  ImplantHandler? getImplantHandler(ImplantFitting fitting) {
    return _implants.firstWhereOrNull((element) => element?.fitting == fitting);
  }

  final ShipFittingLoadout loadout;

  String generateQrCodeData() => loadout.generateQrCodeData();

  static void loadDefinitions(
    ItemRepository itemRepository,
  ) {
    rootBundle.loadString('assets/fitting-patterns.json').then(
          (jsonString) =>
              fittingPatterns = FittingPatterns.fromRawJson(jsonString),
        );

    itemRepository
        .loadFittingCharacter()
        .then((value) => _characterItem = value);
  }

  FittingSimulator._create({
    required ItemRepository itemRepository,
    required AttributeCalculatorService attributeCalculatorService,
    required this.ship,
    required this.loadout,
    this.isDrone = false,
    required Fitting fitting,
    Character? pilot,
    List<ImplantHandler?>? implants,
  })  : _fitting = fitting,
        _itemRepository = itemRepository,
        _attributeCalculatorService = attributeCalculatorService,
        _implants = [null, null],
        capacitorSimulator = CapacitorSimulator(
          attributeCalculatorService: attributeCalculatorService,
          ship: ship,
        ) {
    if (pilot != null) {
      setPilot(pilot);
    }
    if (implants != null) {
      for (var i = 0; i < implants.length; i++) {
        if (implants[i] == null) continue;
        setImplant(implants[i], slot: i);
      }
    }
  }

  static Future<FittingSimulator> fromShipLoadout(
          {required FittingShip ship,
          required ShipFittingLoadout loadout,
          required ItemRepository itemRepository,
          required AttributeCalculatorService attributeCalculatorService,
          required Character pilot,
          List<ImplantHandler?>? implants}) async =>
      FittingSimulator._create(
        attributeCalculatorService: attributeCalculatorService,
        itemRepository: itemRepository,
        ship: ship,
        loadout: loadout,
        pilot: pilot,
        fitting: await itemRepository.fittingDataFromLoadout(
          loadout: loadout,
          attributeCalculatorService: attributeCalculatorService,
        ),
        implants: implants,
      );

  static Future<FittingSimulator> fromDrone(
    FittingShip droneShip, {
    required ShipFittingLoadout loadout,
    required ItemRepository itemRepository,
    required AttributeCalculatorService attributeCalculatorService,
  }) async {
    return FittingSimulator._create(
      ship: droneShip,
      attributeCalculatorService: attributeCalculatorService,
      itemRepository: itemRepository,
      loadout: loadout,
      isDrone: true,
      fitting: await itemRepository.fittingDataFromLoadout(
        loadout: loadout,
        attributeCalculatorService: attributeCalculatorService,
      ),
    );
  }

  Iterable<FittingModule> get _allImplantModules => [
        ..._implants.map((e) => e?.fitting).whereNotNull(),
      ];

  Iterable<FittingModule> get _allFittedModules => [
        ..._allImplantModules,
        ..._fitting.allFittedModules,
      ];

  ///
  ///
  ///
  Duration warpPreparationTime() {
    final mass = getValueForShip(attribute: EveEchoesAttribute.mass);
    final agility =
        getValueForShip(attribute: EveEchoesAttribute.interiaModifier);

    return Duration(
        milliseconds: ((-mass * agility / 1000000 * log(0.2)) * 1000).toInt());
  }

  ///
  ///
  ///
  double maxFlightVelocity() {
    // Get from active AB/MWD
    final activeBoostModule = _fitting.allFittedModules
        .where((module) =>
            module.state != ModuleState.inactive &&
            module.groupId == EveEchoesGroup.propulsion.groupId)
        .firstOrNull;

    final maxVelocity =
        getValueForShip(attribute: EveEchoesAttribute.flightVelocity);

    if (activeBoostModule == null) {
      return maxVelocity;
    }

    final speedBoost = getValueForItem(
        item: activeBoostModule, attribute: EveEchoesAttribute.speedBoost);
    final speedBoostFactor = getValueForItem(
        item: activeBoostModule,
        attribute: EveEchoesAttribute.speedBoostFactor);

    final mass = getValueForShip(attribute: EveEchoesAttribute.mass);

    return (1 + speedBoost * speedBoostFactor / mass) * maxVelocity;
  }

  ///
  /// POWER GRID USAGE
  ///

  double calculatePowerGridUtilisation() {
    return getPowerGridUsage() / getPowerGridOutput();
  }

  double getPowerGridOutput() => getValueForShip(
        attribute: EveEchoesAttribute.powerGridOutput,
      );

  double getPowerGridUsage() {
    var pgCosts = _fitting.allFittedModules.map((item) {
      return getValueForItem(
        attribute: EveEchoesAttribute.powerGridRequirement,
        item: item,
      );
    });

    var totalPGCost = pgCosts.fold(0.0, (dynamic previousValue, pgRequirement) {
      return previousValue + pgRequirement;
    });

    return totalPGCost;
  }

  ///
  /// DEFENSE
  ///

  double calculateTotalEHPForDamagePattern(
    FittingPattern damagePattern,
  ) {
    return kDefenceAttributes.keys
        .map(
          (hpAttribute) => calculateEHPForAttribute(
              hpAttribute: hpAttribute, damagePattern: damagePattern),
        )
        .fold<double>(0, (previousValue, value) => previousValue + value);
  }

  double calculateEHPForAttribute({
    required EveEchoesAttribute hpAttribute,
    required FittingPattern damagePattern,
  }) {
    return _calculateEHPForValue(
      value: rawHPForAttribute(hpAttribute: hpAttribute),
      damagePattern: damagePattern,
      resonanceAttributes: kDefenceAttributes[hpAttribute]!,
    );
  }

  double _calculateEHPForValue({
    required double value,
    required FittingPattern damagePattern,
    required List<EveEchoesAttribute> resonanceAttributes,
  }) {
    final resonances = resonanceAttributes
        .map(
          (e) => getValueForItem(
            attribute: e,
            item: ship,
          ),
        )
        .toList();

    var weighted = (resonances[0] * damagePattern.emPercent) +
        (resonances[1] * damagePattern.thermalPercent) +
        (resonances[2] * damagePattern.kineticPercent) +
        (resonances[3] * damagePattern.explosivePercent);

    return value / weighted;
  }

  double calculateWeakestEHP() {
    // Get HP and resonances
    var values = kDefenceAttributes.entries.map((element) {
      var hpValue = getValueForItem(
        attribute: element.key,
        item: ship,
      );

      var resonances = element.value.map(
        (e) => getValueForItem(
          attribute: e,
          item: ship,
        ),
      );

      var maxResonance = resonances.reduce(max);
      return hpValue / maxResonance;
    });
    var res = values.fold(
        0, (dynamic previousValue, element) => previousValue + element);
    return res;
  }

  double rawHPForAttribute({
    required EveEchoesAttribute hpAttribute,
  }) =>
      getValueForItem(
        attribute: hpAttribute,
        item: ship,
      );

  double getGlobalImplantShieldBonus() {
    final mod = _attributeCalculatorService.implantShieldArmorModifiers
        .where((m) =>
            m.attributeId == EveEchoesAttribute.implantGlobalShield.attributeId)
        .firstOrNull;
    return mod?.attributeValue ?? 0;
  }

  double getGlobalImplantArmorBonus() {
    final mod = _attributeCalculatorService.implantShieldArmorModifiers
        .where((m) =>
    m.attributeId == EveEchoesAttribute.implantGlobalArmor.attributeId)
        .firstOrNull;
    return mod?.attributeValue ?? 0;
  }

  double calculatePassiveShieldRate() {
    final shieldHp = rawHPForAttribute(
      hpAttribute: EveEchoesAttribute.shieldCapacity,
    );

    final shieldRechargeRate = rawHPForAttribute(
      hpAttribute: EveEchoesAttribute.shieldRechargeRate,
    );
    return (10 * shieldHp / (shieldRechargeRate / kSec)) *
        (sqrt(_shieldPercentage) - _shieldPercentage);
  }

  double calculateEhpPassiveShieldRate({
    required FittingPattern damagePattern,
  }) {
    final shieldHp = calculateEHPForAttribute(
      hpAttribute: EveEchoesAttribute.shieldCapacity,
      damagePattern: damagePattern,
    );

    final shieldRechargeRate = rawHPForAttribute(
      hpAttribute: EveEchoesAttribute.shieldRechargeRate,
    );
    return (10 * shieldHp / (shieldRechargeRate / kSec)) *
        (sqrt(_shieldPercentage) - _shieldPercentage);
  }

  double calculateRawShieldBoosterRate() => _fitting.allFittedModules
      .where((module) {
        return (module.slot == SlotType.mid || module.slot == SlotType.low) &&
            module.state == ModuleState.active &&
            module.baseAttributes.any((e) =>
                e.id == EveEchoesAttribute.shieldBoostAmount.attributeId);
      })
      .map(_calculateRawShieldBoosterRateForModule)
      .fold(0, (previousValue, next) => previousValue + next);

  double _calculateRawShieldBoosterRateForModule(FittingModule module) {
    final repairAmount = getValueForItem(
      attribute: EveEchoesAttribute.shieldBoostAmount,
      item: module,
    );
    final cycleTime = getValueForItem(
      attribute: EveEchoesAttribute.activationTime,
      item: module,
    );
    return repairAmount / (cycleTime / kSec);
  }

  double calculateEhpShieldBoosterRate({
    required FittingPattern damagePattern,
  }) =>
      _fitting.allFittedModules
          .where((module) {
            return (module.slot == SlotType.mid ||
                    module.slot == SlotType.low) &&
                module.state == ModuleState.active &&
                module.baseAttributes.any((e) =>
                    e.id == EveEchoesAttribute.shieldBoostAmount.attributeId);
          })
          .map(
            (e) => _calculateEhpShieldBoosterRateForModule(
              e,
              damagePattern: damagePattern,
            ),
          )
          .fold(0, (previousValue, next) => previousValue + next);

  double _calculateEhpShieldBoosterRateForModule(
    FittingModule module, {
    required FittingPattern damagePattern,
  }) {
    final repairAmount = _calculateEHPForValue(
      value: getValueForItem(
        attribute: EveEchoesAttribute.shieldBoostAmount,
        item: module,
      ),
      damagePattern: damagePattern,
      resonanceAttributes:
          kDefenceAttributes[EveEchoesAttribute.shieldCapacity]!,
    );
    final cycleTime = getValueForItem(
      attribute: EveEchoesAttribute.activationTime,
      item: module,
    );
    return repairAmount / (cycleTime / kSec);
  }

  double calculateRawArmorRepairRate() => _fitting.allFittedModules
      .where((module) {
        return (module.slot == SlotType.mid || module.slot == SlotType.low) &&
            module.state == ModuleState.active &&
            module.baseAttributes
                .any((e) => e.id == EveEchoesAttribute.armorRepair.attributeId);
      })
      .map(_calculateArmorRepairRateForModule)
      .fold(0, (previousValue, next) => previousValue + next);

  double _calculateArmorRepairRateForModule(FittingModule module) {
    final repairAmount = getValueForItem(
      attribute: EveEchoesAttribute.armorRepair,
      item: module,
    );
    final cycleTime = getValueForItem(
      attribute: EveEchoesAttribute.activationTime,
      item: module,
    );
    return repairAmount / (cycleTime / kSec);
  }

  double calculateEhpArmorRepairRate({
    required FittingPattern damagePattern,
  }) =>
      _fitting.allFittedModules
          .where((module) {
            return (module.slot == SlotType.mid ||
                    module.slot == SlotType.low) &&
                module.state == ModuleState.active &&
                module.baseAttributes.any(
                    (e) => e.id == EveEchoesAttribute.armorRepair.attributeId);
          })
          .map(
            (e) => _calculateEhpArmorRepairRateForModule(
              e,
              damagePattern: damagePattern,
            ),
          )
          .fold(0, (previousValue, next) => previousValue + next);

  double _calculateEhpArmorRepairRateForModule(
    FittingModule module, {
    required FittingPattern damagePattern,
  }) {
    final repairAmount = _calculateEHPForValue(
      value: getValueForItem(
        attribute: EveEchoesAttribute.armorRepair,
        item: module,
      ),
      damagePattern: damagePattern,
      resonanceAttributes: kDefenceAttributes[EveEchoesAttribute.armorHp]!,
    );
    final cycleTime = getValueForItem(
      attribute: EveEchoesAttribute.activationTime,
      item: module,
    );
    return repairAmount / (cycleTime / kSec);
  }

  ///
  /// MINING
  ///

  double calculateTotalMiningYeild() {
    return _fitting
        .fittedModulesForSlot(SlotType.high)
        .where((module) {
          return module.baseAttributes
              .any((e) => e.id == EveEchoesAttribute.miningAmount.attributeId);
        })
        .map(calculateMiningYeildForModule)
        .fold(0, (previousValue, next) => previousValue + next);
  }

  double calculateTotalMiningYeildPerMinute() {
    return _fitting
        .fittedModulesForSlot(SlotType.high)
        .where((module) {
          return module.baseAttributes
              .any((e) => e.id == EveEchoesAttribute.miningAmount.attributeId);
        })
        .map(calculateMiningYeildPerMinuteForModule)
        .fold(0, (previousValue, next) => previousValue + next);
  }

  Duration calculateMiningTimeToFill() {
    final ypmTurrents = calculateTotalMiningYeildPerMinute();
    final ypmDrones = calculateTotalMiningYeildPerMinuteForDrones();
    final ypm = ypmTurrents + ypmDrones;
    final holdSize = getValueForShip(
      attribute: EveEchoesAttribute.oreHoldCapacity,
    );

    return Duration(
      seconds: ((ypm > 0 ? holdSize / ypm : 0) * 60.0).toInt(),
    );
  }

  double calculateMiningYeildForModule(FittingModule module) => getValueForItem(
        attribute: EveEchoesAttribute.miningAmount,
        item: module,
      );

  double calculateMiningYeildPerMinuteForModule(FittingModule module) =>
      calculateMiningYeildForModule(module) /
      (getValueForItem(
            attribute: EveEchoesAttribute.activationTime,
            item: module,
          ) /
          kMinute);

  ///
  /// OFFENCE
  ///
  ///

  bool _isItemMissile(int id) {
    var groupId = id / Group.itemToGroupIdDivisor;
    return (groupId >= 11012 && groupId <= 11023) ||
        (groupId >= 24000 && groupId <= 24999);
  }

  bool _isItemTurret(int id) {
    var groupId = id / Group.itemToGroupIdDivisor;
    return (groupId >= 11000 && groupId <= 11005);
  }

  ///
  /// DPS
  ///

  double calculateTotalDps() {
    var highSlotDps = calculateTotalDpsForModules();
    var droneDps = calculateTotalDpsForDrones();
    final dps = highSlotDps + droneDps;
    //print("DPS: $dps (ship id ${ship.itemId})");
    return dps;
  }

  double calculateTotalDpsForModules({WeaponType weaponType = WeaponType.all}) {
    if (weaponType == WeaponType.drone) {
      return calculateTotalDpsForDrones();
    }

    var modules = _fitting.fittedModulesForSlot(SlotType.high).where((module) {
      if (weaponType == WeaponType.turret) {
        return _isItemTurret(module.itemId);
      } else if (weaponType == WeaponType.missile) {
        return _isItemMissile(module.itemId);
      }
      return true;
    });

    return modules
        .map(
          (item) => calculateDpsForItem(
            item: item,
          ),
        )
        .fold<double>(
          0.0,
          (previousValue, itemDps) => previousValue + itemDps,
        );
  }

  double calculateDpsForItem({
    required FittingModule item,
  }) {
    final activationTimeDefinition = item.baseAttributes.firstWhereOrNull(
      (element) => element.id == EveEchoesAttribute.activationTime.attributeId,
    );
    var activationTime = 0.0;
    if (activationTimeDefinition != null) {
      activationTime = getValueForItem(
        attribute: EveEchoesAttribute.activationTime,
        item: item,
      );
      activationTime =
          activationTimeDefinition.calculatedValue(fromValue: activationTime);
    }
    if (activationTime == 0.0) return 0;

    return calculateAlphaStrikeForItem(item: item) / activationTime;
  }

  ///
  /// Alpha Strike
  ///

  double calculateTotalAlphaStrike({EveEchoesAttribute? damageType}) {
    var highSlotDps = calculateTotalAlphaStrikeForModules(damageType: damageType);
    var droneDps = calculateTotalAlphaStrikeForDrones(damageType: damageType);

    return highSlotDps + droneDps;
  }

  double calculateTotalAlphaStrikeForModules(
      {WeaponType weaponType = WeaponType.all, EveEchoesAttribute? damageType}) {
    if (weaponType == WeaponType.drone) {
      return calculateTotalAlphaStrikeForDrones(damageType: damageType);
    }

    var modules = _fitting.fittedModulesForSlot(SlotType.high).where((module) {
      if (weaponType == WeaponType.turret) {
        return _isItemTurret(module.itemId);
      } else if (weaponType == WeaponType.missile) {
        return _isItemMissile(module.itemId);
      }
      return true;
    });

    return modules
        .map(
          (item) => calculateAlphaStrikeForItem(
            item: item,
            damageType: damageType,
          ),
        )
        .fold<double>(
          0.0,
          (previousValue, itemDps) => previousValue + itemDps,
        );
  }

  double calculateAlphaStrikeForItem({
    required FittingModule item,
    EveEchoesAttribute? damageType,
  }) {
    if (item.state == ModuleState.inactive) return 0;
    double emDamage = 0;
    double thermDamage = 0;
    double kinDamage = 0;
    double expDamage = 0;

    // EM damage
    if (damageType == null || damageType == EveEchoesAttribute.emDamage) {
      emDamage = getValueForItem(
        attribute: EveEchoesAttribute.emDamage,
        item: item,
      );
    }

    // Thermal damage
    if (damageType == null || damageType == EveEchoesAttribute.thermalDamage) {
      thermDamage = getValueForItem(
        attribute: EveEchoesAttribute.thermalDamage,
        item: item,
      );
    }

    // Kinetic damage
    if (damageType == null || damageType == EveEchoesAttribute.kineticDamage) {
      kinDamage = getValueForItem(
        attribute: EveEchoesAttribute.kineticDamage,
        item: item,
      );
    }

    // Explosive damage
    if (damageType == null || damageType == EveEchoesAttribute.explosiveDamage) {
      expDamage = getValueForItem(
        attribute: EveEchoesAttribute.explosiveDamage,
        item: item,
      );
    }

    return (emDamage + thermDamage + kinDamage + expDamage);
  }

  ///
  /// DRONES
  ///

  double calculateTotalDpsForDrones() {
    final moduleSlots = [
      SlotType.drone,
      SlotType.lightDDSlot,
      SlotType.lightFFSlot,
    ];
    return moduleSlots
        .map(_fitting.fittedModulesForSlot)
        .expand((e) => e)
        .where((d) => d.state != ModuleState.inactive)
        .map(
          (drone) => calculateDpsForDrone(
            drone: drone as FittingDrone,
          ),
        )
        .fold<double>(0.0, (previousValue, itemDps) => previousValue + itemDps);
  }

  double calculateTotalAlphaStrikeForDrones({EveEchoesAttribute? damageType}) {
    final moduleSlots = [
      SlotType.drone,
      SlotType.lightDDSlot,
      SlotType.lightFFSlot,
    ];
    return moduleSlots
        .map(_fitting.fittedModulesForSlot)
        .expand((e) => e)
        .where((d) => d.state != ModuleState.inactive)
        .map(
          (drone) => calculateAlphaStrikeForDrone(
            drone: drone as FittingDrone,
          ),
        )
        .fold<double>(0.0, (previousValue, itemDps) => previousValue + itemDps);
  }

  double calculateDpsForDrone({
    required FittingDrone drone,
  }) {
    final multiplier = getValueForItem(
        attribute: EveEchoesAttribute.fighterNumberLimit, item: drone);
    return drone.fitting.calculateTotalDps() * max(multiplier, 1);
  }

  double calculateAlphaStrikeForDrone({
    required FittingDrone drone,
  }) {
    final multiplier = getValueForItem(
        attribute: EveEchoesAttribute.fighterNumberLimit, item: drone);
    return drone.fitting.calculateTotalAlphaStrike() * max(multiplier, 1);
  }

  double calculateMiningYeildForDrone({
    required FittingDrone drone,
  }) {
    final multiplier = getValueForItem(
        attribute: EveEchoesAttribute.fighterNumberLimit, item: drone);
    return drone.fitting.calculateTotalMiningYeild() * max(multiplier, 1);
  }

  double calculateTotalMiningYeildForDrones() {
    return _fitting
        .fittedModulesForSlot(SlotType.drone)
        .where((d) => d.state != ModuleState.inactive)
        .map(
          (drone) => calculateMiningYeildForDrone(
            drone: drone as FittingDrone,
          ),
        )
        .fold<double>(
            0.0, (previousValue, itemYield) => previousValue + itemYield);
  }

  double calculateTotalMiningYeildPerMinuteForDrone({
    required FittingDrone drone,
  }) =>
      drone.fitting.calculateTotalMiningYeildPerMinute();

  double calculateTotalMiningYeildPerMinuteForDrones() => _fitting
      .fittedModulesForSlot(SlotType.drone)
      .where((d) => d.state != ModuleState.inactive)
      .map(
        (drone) => calculateTotalMiningYeildPerMinuteForDrone(
          drone: drone as FittingDrone,
        ),
      )
      .fold<double>(0.0, (previousValue, itemYpm) => previousValue + itemYpm);

  ///
  /// Get Attribute Value
  ///

  double getValueForShip({
    required EveEchoesAttribute attribute,
  }) =>
      getValueForItem(
        item: ship,
        attribute: attribute,
      );

  double _getValueForShipWithAttributeId({
    required int attributeId,
  }) =>
      _attributeCalculatorService.getValueForItemWithAttributeId(
        attributeId: attributeId,
        item: ship,
      );

  ///
  /// Getting values for characters, the base values come from a special
  /// item numbered 93000000000 - 93000400002 but I guess for EE there is
  /// really only one, and these are duplicated? (TBC)
  double getValueForCharacter({
    required EveEchoesAttribute attribute,
  }) =>
      getValueForItem(
        attribute: attribute,
        item: _characterItem,
      );

  bool fitItem(
    FittingModule module, {
    required SlotType slot,
    required int index,
    bool notify = true,
    ModuleState state = ModuleState.active,
  }) {
    if (!module.isValid && slot == SlotType.implantSlots) {
      // Delete implant
      setImplant(null, slot: index);
      return true;
    }
    var fittedModule = (module).copyWith(
      slot: slot,
      index: index,
    );

    if (!canFitModule(module: fittedModule, slot: slot)) return false;

    _fitting[slot]![index] = fittedModule.copyWith(
      state: _canActivateModule(fittedModule) ? state : ModuleState.inactive,
    );

    loadout.fitItem(_fitting[slot]![index]);

    if (notify) {
      _updateFitting();
    }

    return true;
  }

  bool cloneFittedItem({
    required SlotType slot,
    required int index,
    bool notify = true,
    ModuleState state = ModuleState.active,
  }) {
    int? emptySlot;
    for (int i = 0; i < _fitting[slot]!.length; i++) {
      if (_fitting[slot]![i] == FittingModule.empty) {
        emptySlot = i;
        break;
      }
    }
    if (emptySlot == null) return false;
    FittingModule module = _fitting[slot]![index];
    if (module == FittingModule.empty) return false;
    return fitItem(module,
        slot: slot, index: emptySlot, notify: notify, state: state);
  }

  void fitItemIntoAll(
    FittingModule module, {
    required SlotType slot,
    bool notify = true,
  }) {
    final slotList = _fitting[slot] ?? [];
    slotList.forEachIndexed(
      (index, _) => fitItem(
        module,
        slot: slot,
        index: index,
        notify: false,
      ),
    );

    if (notify) {
      _updateFitting();
    }
  }

  bool fitNanocoreAffix(FittingNanocoreAffix? affix,
      {required int index, required bool active, bool notify = true}) {
    final FittingNanocore? nanocore =
        modules(slotType: SlotType.nanocore).firstOrNull as FittingNanocore?;
    if (nanocore == null) {
      return false;
    }

    if (affix != null && nanocore.hasAffix(affix.affixGroup)) {
      return false;
    }

    if (active) {
      nanocore.extraAffixes[index] = affix;
    } else {
      if (affix == null) {
        if (nanocore.passiveAffixes.length == 1) {
          nanocore.passiveAffixes[0] = null;
        } else {
          nanocore.passiveAffixes.removeAt(index);
        }
      } else {
        nanocore.passiveAffixes[index] = affix;
        if (nanocore.passiveAffixes.last != null) {
          nanocore.passiveAffixes.add(null);
        }
      }
    }
    if (notify) _updateFitting();
    return true;
  }

  // FUTURENOTE: This would be better in another spot
  int numSlotsForType(SlotType slotType) {
    final EveEchoesAttribute numSlotAttr;
    switch (slotType) {
      case SlotType.high:
        numSlotAttr = EveEchoesAttribute.highSlotCount;
        break;
      case SlotType.mid:
        numSlotAttr = EveEchoesAttribute.midSlotCount;
        break;
      case SlotType.low:
        numSlotAttr = EveEchoesAttribute.lowSlotCount;
        break;
      case SlotType.combatRig:
        numSlotAttr = EveEchoesAttribute.combatRigSlotCount;
        break;
      case SlotType.engineeringRig:
        numSlotAttr = EveEchoesAttribute.engineeringRigSlotCount;
        break;
      case SlotType.drone:
        numSlotAttr = EveEchoesAttribute.droneBayCount;
        break;
      case SlotType.nanocore:
        // TODO: HACK: This is stupid, and I don't understand why this isn't in the data
        // but lets be honest - NetEase hates me and wants me to cry T-T
        // We are just going to feed back the same number we had - because
        // AS OF RIGHT NOW THIS DOES NOT CHANGE
        numSlotAttr = EveEchoesAttribute.nanocoreSlotCount;
        return loadout.nanocoreSlots.maxSlots;
      case SlotType.lightFFSlot:
        numSlotAttr = EveEchoesAttribute.lightFFSlot;
        break;
      case SlotType.lightDDSlot:
        numSlotAttr = EveEchoesAttribute.lightDDSlot;
        break;
      case SlotType.hangarRigSlots:
        numSlotAttr = EveEchoesAttribute.hangarRigSlots;
        break;
      case SlotType.implantSlots:
        // Implants behaves like normal modules, but don't get
        // fitted into normal slots
        return 0;
    }

    return getValueForShip(attribute: numSlotAttr).toInt();
  }

  void _updateFittingLoadout() {
    // FUTURENOTE: This is a stop gap for now - as it would be better that
    // the app does not rely on the static numbering at all!
    final updatedLoadout = ShipLoadoutDefinition(
      numHighSlots: numSlotsForType(SlotType.high),
      numMidSlots: numSlotsForType(SlotType.mid),
      numLowSlots: numSlotsForType(SlotType.low),
      numDroneSlots: numSlotsForType(SlotType.drone),
      numCombatRigSlots: numSlotsForType(SlotType.combatRig),
      numEngineeringRigSlots: numSlotsForType(SlotType.engineeringRig),
      numNanocoreSlots: numSlotsForType(SlotType.nanocore),
      numLightFrigatesSlots: numSlotsForType(SlotType.lightFFSlot),
      numLightDestroyersSlots: numSlotsForType(SlotType.lightDDSlot),
      numHangarRigSlots: numSlotsForType(SlotType.hangarRigSlots),
    );

    _fitting.updateLoadout(updatedLoadout);
    loadout.updateSlotDefinition(updatedLoadout);
  }

  void _updateFitting() => _attributeCalculatorService
      .updateItems(allFittedModules: _allFittedModules)
      .then((_) => _updateFittingLoadout())
      .then((_) => notifyListeners());

  void updateLoadout() {
    _fitting.allFittedModules.forEach(loadout.fitItem);
    _updateFitting();
  }

  Future<String> printFitting(
    LocalisationRepository localisationRepository,
    ItemRepository itemRepository,
  ) async {
    final items = _fitting.allFittedModules;

    // Need to work out how best to incorporate Rig Integrator counts here
    final itemsGrouped = groupBy<FittingModule, int>(items, (e) => e.groupKey);
    final shipName = localisationRepository.getLocalisedNameForItem(ship.item);

    final strings = await Future.wait(itemsGrouped.entries.map((itemKvp) async {
      final module = items.firstWhereOrNull(
        (e) => e.groupKey == itemKvp.key,
      );

      if (module == null) return '';

      var itemName = localisationRepository.getLocalisedNameForItem(
        module.item,
      );

      if (module is FittingNanocore) {
        if (module.mainAttribute.selectedModifier != null) {
          final modifier =
              await module.mainAttribute.selectedModifier!.modifierName(
            localisation: localisationRepository,
            itemRepository: itemRepository,
          );
          itemName += '\n\t$modifier';
        }
        if (module.secondMainAttribute?.selectedModifier != null) {
          final modifier =
              await module.secondMainAttribute!.selectedModifier!.modifierName(
            localisation: localisationRepository,
            itemRepository: itemRepository,
          );
          itemName += '\n\t$modifier';
        }

        final modifiers = module.trainableAttributes
            .where((e) => e.selectedModifier != null)
            .map((e) => e.selectedModifier as ItemModifier);

        for (final modifier in modifiers) {
          final modifierName = await modifier.modifierName(
            localisation: localisationRepository,
            itemRepository: itemRepository,
          );
          itemName += '\n\t$modifierName';
        }
        final hasActive = module.extraAffixes.any((e) => e != null);
        final hasPassive = module.extraAffixes.any((e) => e != null);
        if (hasActive || hasPassive) {
          itemName += '\nNanocore Library';
          if (hasActive) {
            itemName += '\n\tActive:';
          }
          for (final affix in module.extraAffixes) {
            if (affix == null) continue;
            final modifierName = await affix.modifiers[0].modifierName(
              localisation: localisationRepository,
              itemRepository: itemRepository,
            );
            itemName += '\n\t\t$modifierName (Lvl. ${affix.selectedLevel})';
          }
          if (hasActive || hasPassive) {
            itemName += '\n\tPassive:';
          }
          for (final affix in [
            ...module.extraAffixes,
            ...module.passiveAffixes
          ]) {
            if (affix == null) continue;
            final modifierName = await affix.passiveModifiers[0].modifierName(
              localisation: localisationRepository,
              itemRepository: itemRepository,
            );
            itemName += '\n\t\t$modifierName (Lvl. ${affix.selectedLevel})';
          }
        }
      }

      if (module is FittingRigIntegrator) {
        final names = module.integratedRigs
            .map((e) => e.item)
            .map(localisationRepository.getLocalisedNameForItem);

        itemName += ':\n\t${names.join('\n\t')}';
      }

      return '${itemKvp.value.length}x $itemName';
    }));
    for (var implant in implants) {
      if (implant == null) continue;
      var implantName = localisationRepository.getLocalisedNameForItem(
        implant.item,
      );
      implantName += ' Level ${implant.trainedLevel}';
      for (var mod in implant.allModules.sorted((a, b) => a.level - b.level)) {
        if (!mod.isValid) continue;
        var modName = localisationRepository.getLocalisedNameForItem(mod.item);
        var slotName = '${mod.slot.name} ${mod.level}'.capitalize();
        implantName += "\n\t$slotName: $modName";
      }
      strings.add(implantName);
    }

    final fittingString = strings.join('\n');

    return '$name\n[$shipName]\n\n$fittingString';
  }

  ///
  /// Forward calls for now, as we refactor
  double getValueForItem({
    required EveEchoesAttribute attribute,
    required FittingItem item,
  }) =>
      _attributeCalculatorService.getValueForItem(
        attribute: attribute,
        item: item,
        isDrone: isDrone,
      );

  double getValueForItemWithAttributeId({
    required int attributeId,
    required FittingItem item,
  }) =>
      _attributeCalculatorService.getValueForItemWithAttributeId(
        attributeId: attributeId,
        item: item,
        isDrone: isDrone,
      );

  double getValueForItemWithAttrOrId({
    required EveEchoesAttributeOrId attrOrId,
    required FittingItem item,
  }) {
    if (attrOrId.attribute != null) {
      return getValueForItem(
        attribute: attrOrId.attribute!,
        item: item,
      );
    } else {
      return getValueForItemWithAttributeId(
        attributeId: attrOrId.id,
        item: item,
      );
    }
  }

  Future<void> updateAttributes({
    List<FittingSkill> skills = const [],
  }) async {
    await _attributeCalculatorService
        .setup(
          skills: skills,
          ship: ship,
          allFittedModules: _allFittedModules,
        )
        .then((value) => notifyListeners());
  }

  void updateNihilusModifiers(List<NihilusSpaceModifier> modifiers) {
    _attributeCalculatorService
        .updateNihilusModifiers(modifiers: modifiers)
        .then((value) => notifyListeners());
  }

  void updateImplantLevels({bool notify = true}) {
    if (notify) {
      _attributeCalculatorService
          .updateImplantLevels(totalLevels: totalImplantLevels)
          .then((value) => notifyListeners());
    } else {
      _attributeCalculatorService.updateImplantLevels(
        totalLevels: totalImplantLevels,
      );
    }
  }

  void updateShieldPercentage(double shieldPercentage) {
    _shieldPercentage = shieldPercentage;
    notifyListeners();
  }

  Future<CapacitorSimulationResults> capacitorSimulation() =>
      capacitorSimulator.simulate(
        itemRepository: _itemRepository,
        allFittedModules: _fitting.allFittedModules,
      );

  double getValueForSlot({
    required EveEchoesAttribute attribute,
    required SlotType slot,
    required int index,
  }) {
    return getValueForItem(
      item: _fitting[slot]![index],
      attribute: attribute,
    );
  }

  Future<double> calculateDpsForSlotIndex({
    required SlotType slot,
    required int index,
  }) async {
    return calculateDpsForItem(
      item: _fitting[slot]![index],
    );
  }

  Future<void> updateSkills({List<LearnedSkill> skills = const []}) async {
    final fittingSkills =
        await _itemRepository.fittingSkillsFromLearned(skills);
    await updateAttributes(skills: fittingSkills.toList());
  }

  void setShipMode({required bool enabled}) {
    ship.setShipModeEnabled(enabled);

    _attributeCalculatorService
        .updateItems(allFittedModules: _allFittedModules)
        .then((_) => notifyListeners());
  }

  void setModuleState(
    ModuleState newState, {
    required SlotType slot,
    required int index,
  }) {
    if (slot == SlotType.implantSlots) return;

    final module = _fitting[slot]![index];
    if (newState != ModuleState.inactive && !_canActivateModule(module)) {
      // Check it can be overloaded/activated
      final activatedGroup = _fitting.allFittedModules.where(
        (m) => m.state != ModuleState.inactive && m.groupId == module.groupId,
      );
      for (var m in activatedGroup) {
        _fitting[m.slot]![m.index] = m.copyWith(
          state: ModuleState.inactive,
        );
      }
    }

    _fitting[module.slot]![module.index] = module.copyWith(
      state: newState,
    );
    loadout.fitItem(_fitting[module.slot]![module.index]);

    _attributeCalculatorService
        .updateItems(allFittedModules: _allFittedModules)
        .then((_) => notifyListeners());
  }

  void setImplantModuleState(ModuleState newState,
      {required int slotIndex, required int implantSlotId}) {
    final implant = _implants[slotIndex]!;
    if (implantSlotId == 0) {
      implant.fitting.primarySkillState = newState;
    } else {
      // print("Toggle state to $newState");
      final module = implant.fitting[implantSlotId]!;
      implant.fitting[implantSlotId] = module.copyWith(state: newState);
      implant.loadout.fitItem(implant.fitting[implantSlotId]!, implantSlotId);
    }
    _attributeCalculatorService
        .updateItems(allFittedModules: _allFittedModules)
        .then((_) => notifyListeners());
    // print("Toggled state to ${_implant!.fitting[slotId]!.state}");
  }

  bool canFitModule({required FittingModule module, required SlotType? slot}) {
    if (module == FittingModule.empty) return true;

    // Check for moduleCanFitAttributeID
    final canFitAttributeId = module.baseAttributes.firstWhereOrNull(
        (a) => a.id == EveEchoesAttribute.moduleCanFitAttributeID.attributeId);

    if (canFitAttributeId != null) {
      final canFit = _getValueForShipWithAttributeId(
        attributeId: canFitAttributeId.baseValue.toInt(),
      );

      if (canFit == 0.0) return false;
    }

    // check module size
    // only drones for now, as there is no UI to fit others
    if (module is FittingDrone) {
      var moduleSize = module.baseAttributes
              .firstWhereOrNull(
                  (a) => a.id == EveEchoesAttribute.moduleSize.attributeId)
              ?.baseValue ??
          double.maxFinite;
      var droneBandwidth =
          getValueForShip(attribute: EveEchoesAttribute.droneBandwidth);

      return moduleSize <= droneBandwidth;
    }

    final maxGroupActive = module.baseAttributes
            .firstWhereOrNull(
                (a) => a.id == EveEchoesAttribute.maxGroupFitted.attributeId)
            ?.baseValue ??
        double.maxFinite;

    final fittedModulesInGroup = _fitting.allFittedModules.where(
      (m) => m.groupId == module.groupId && !m.inSameSlot(module),
    );

    return fittedModulesInGroup.length < maxGroupActive.toInt();
  }

  bool _canActivateModule(FittingModule module) {
    if (module == FittingModule.empty) return false;

    final maxGroupActive = module.baseAttributes
            .firstWhereOrNull(
                (a) => a.id == EveEchoesAttribute.maxGroupActive.attributeId)
            ?.baseValue ??
        double.maxFinite;

    final activeModulesInGroup = _fitting.allFittedModules.where(
      (m) =>
          m.groupId == module.groupId &&
          m.state != ModuleState.inactive &&
          !m.inSameSlot(module),
    );

    return activeModulesInGroup.length < maxGroupActive.toInt();
  }
}
