import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: depend_on_referenced_packages
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

import 'package:sweet/model/character/character.dart';
import 'package:sweet/model/character/learned_skill.dart';
import 'package:sweet/model/fitting/fitting_patterns.dart';
import 'package:sweet/model/fitting/fitting_ship.dart';
import 'package:sweet/model/implant/implant_fitting_loadout.dart';
import 'package:sweet/model/implant/implant_handler.dart';
import 'package:sweet/model/items/eve_echoes_categories.dart';
import 'package:sweet/model/items/skills.dart';
import 'package:sweet/model/ship/eve_echoes_attribute.dart';
import 'package:sweet/model/ship/module_state.dart';
import 'package:sweet/service/fitting_simulator.dart';
import 'package:sweet/model/ship/ship_fitting_loadout.dart';
import 'package:sweet/model/ship/slot_type.dart';
import 'package:sweet/repository/item_repository.dart';
import 'package:sweet/service/attribute_calculator_service.dart';
import 'package:sweet/util/constants.dart';

import 'mock_platform_paths.dart';

/// Helper to await the next notification from a FittingSimulator, i.e. the next
/// calculation update.
Future<void> waitForNextNotification(FittingSimulator fitting,
    {Duration timeout = const Duration(seconds: 2)}) {
  final completer = Completer<void>();
  void listener() {
    if (!completer.isCompleted) {
      completer.complete();
      fitting.removeListener(listener);
    }
  }

  fitting.addListener(listener);

  return completer.future.whenComplete(() {
    if (fitting.hasListeners) fitting.removeListener(listener);
  }).timeout(timeout, onTimeout: () {
    fitting.removeListener(listener);
    throw TimeoutException('Timed out waiting for FittingSimulator notification');
  });
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Ensure Nurf Denominators are correct', () {
    var expected = [
      1.0,
      0.869201150346033,
      0.5707963267948966,
      0.2831930766489234,
      0.10615114392969364,
      0.030061269039252634,
      0.0064317703161929345,
      0.0010396671655238492
    ];

    for (var i = 0; i < kNurfDenominators.length; i++) {
      expect(kNurfDenominators[i], expected[i]);
    }
  });

  group('Data tests >', () {
    var itemRepo = ItemRepository();
    var attrCalc = AttributeCalculatorService(itemRepository: itemRepo);

    setUpAll(() async {
      // Load item repo
      print('Loading files');
      PathProviderPlatform.instance = MockPathProviderPlatform();
      SharedPreferences.setMockInitialValues({}); //set values here
      await itemRepo.openDatabase();
      print('Loading initial data');
      await itemRepo.processLevelAttributes();
      await itemRepo.processGoldNanoAttrClasses();
    });

    group('Individual Items', () {
      test('Mk.VII Armored Command Burst', () async {
        final module = await itemRepo.module(id: 11125100008);
        final skills = await itemRepo.fittingSkillsFromLearned([
          LearnedSkill(skillId: 49340000013, skillLevel: 5),
        ]);

        final armorBaseValue = attrCalc.getValueForItemWithAttributeId(
            attributeId: 1506, item: module);
        expect(armorBaseValue, 0.0731);

        await attrCalc.setup(
          skills: skills.toList(),
          ship: FittingShip.empty,
        );

        final armorLv5Value = attrCalc.getValueForItemWithAttributeId(
            attributeId: 1506, item: module);
        expect(armorLv5Value.toStringAsFixed(5), '0.08772');
      });

      test(
        'Mk9 Drone Damage Amp',
        () async {
          print(DateTime.now());
          final module = await itemRepo.module(id: 11519000010);
          print(DateTime.now());
          final skills = await itemRepo.fittingSkillsFromDbSkills();

          final armorBaseValue = attrCalc.getValueForItemWithAttributeId(
              attributeId: 430, item: module);
          expect(armorBaseValue, 20000);

          print(DateTime.now());
          await attrCalc.setup(
            skills: skills.toList(),
            ship: FittingShip.empty,
          );

          print(DateTime.now());
          final armorLv5Value = attrCalc.getValueForItemWithAttributeId(
              attributeId: 430, item: module);
          expect(armorLv5Value, 44000);
        },
        skip:
            'This should only be run manually for now until someone minimises the number of skills loaded',
      );

      test('Freq Reducing 3P Engineering Integrator', () async {
        final rigIntegrator = await itemRepo.rigIntegrator(id: 11721010002);

        final dynamicValveRig = await itemRepo.module(id: 11710000006);
        final auxilaryThrusterRig = await itemRepo.module(id: 11710010006);
        final polycarbHousingRig = await itemRepo.module(id: 11710020006);

        var canFit = rigIntegrator.canFit(rig: dynamicValveRig);
        expect(canFit, true, reason: 'Expect to fit Dynamic Valve rig');

        canFit = rigIntegrator.canFit(rig: auxilaryThrusterRig);
        expect(canFit, true, reason: 'Expect to fit Auxiliary Thrusters rig');

        canFit = rigIntegrator.canFit(rig: polycarbHousingRig);
        expect(canFit, true,
            reason: 'Expect to fit Polycarb Engine Housing rig');

        rigIntegrator.fit(rig: dynamicValveRig, index: 0);
        rigIntegrator.fit(rig: auxilaryThrusterRig, index: 1);
        rigIntegrator.fit(rig: polycarbHousingRig, index: 2);

        final capNeedAdj = dynamicValveRig.modifiers.firstWhere(
          (m) =>
              m.attributeId ==
              EveEchoesAttribute.enableCapacitorNeedAdjustment.attributeId,
        );
        expect(capNeedAdj.attributeValue, -0.4);

        final rigCapNeedAdj = rigIntegrator.modifiers.firstWhere(
          (m) =>
              m.attributeId ==
              EveEchoesAttribute.enableCapacitorNeedAdjustment.attributeId,
        );

        expect(
          rigCapNeedAdj.attributeValue,
          -0.24,
        );

        final rigCapNeedAdjAttribute = rigIntegrator.baseAttributes.firstWhere(
          (attr) =>
              attr.id ==
              EveEchoesAttribute.enableCapacitorNeedAdjustment.attributeId,
        );

        expect(
          rigCapNeedAdjAttribute.baseValue,
          -0.24,
        );

        // await attrCalc.setup(
        //   skills: [],
        //   ship: FittingShip.empty,
        // );
      });
    });

    group('Ship Mode Tests', () {
      test('Max Velocity (Bomber)', () async {
        var ship = await itemRepo.ship(
          id: 10100000322,
        );

        final fitting = await FittingSimulator.fromShipLoadout(
          pilot: Character.empty,
          attributeCalculatorService: attrCalc,
          itemRepository: itemRepo,
          ship: ship,
          loadout: ShipFittingLoadout.fromShip(ship.itemId,
              await itemRepo.getShipLoadoutDefinition(ship.itemId)),
        );

        fitting.setShipMode(enabled: false);
        await fitting.updateSkills();

        final velocity = fitting.maxFlightVelocity();
        expect(velocity, 363.0);

        fitting.setShipMode(enabled: true);

        await fitting.updateSkills();

        final modified = fitting.maxFlightVelocity();
        expect(modified.toStringAsFixed(2), '18.15');
      });
    });

    group('Drone Tests', () {
      test('MK5 Hammerhead', () async {
        var drone = await itemRepo.drone(
          id: 14000120006,
          attributeCalculatorService: attrCalc,
        );

        await drone.fitting.updateSkills();

        var droneDps = drone.fitting.calculateTotalDps();

        expect(
          droneDps.toStringAsFixed(2),
          '20.27',
        );

        var charData =
            'QlpoOTFBWSZTWdnh5wQABlRfgDAAUAZ/8AAkCAo/b50qQAH9lEadhlQAMhpoAANNANMRCKGnpqHlBkAAGnqUARgmIDIZGjAiSmgRpMgyBoZAZMFRP7218ePIUIqJEB/OB07CKiRURwGuu3bsyZPchxFMOyEm1pQZdLbSpvLtNmi0iU2WTezdU6pCpwklvduKwF/CIEDXIekVEsPflcKiXZ3Vs0koqBJIhV2q8tJKIIKCBQJIUFUQiSWCQpSaISmpLfHeiSBBIjcRLsBwQQQBDeNMiW5SaBavGkAeCQBiAsTmATAxec6nKumZTNTJc5xmYMCOWnPLAs1VatlrSWkKoyHZyzBDTsBkwHAR3QvEALF8y7cQwA0lQDEcTCWLBWJaVEJctFQpqyCGMFv1c96Ap5iohz3RF8yG4B1T62bkkEWJW21UnxJBHRJBCVyM8Kon0KiVn3KiQVEv3AClbb7ddvW/C8VE32zVE18Pt6RQTw90kkkkCRk8qpJ3ScEwMMDAwCdwWjvAwCQgEeoPvxdyRThQkNnh5wQ=';
        var char = Character.fromQrCodeData(charData);
        var skills = char.learntSkills;

        await drone.fitting.updateSkills(skills: skills);

        droneDps = drone.fitting.calculateTotalDps();

        expect(
          droneDps.toStringAsFixed(2),
          '26.56',
        );
      });

      test('Heavy Dust Salvage Drone', () async {
        var drone = await itemRepo.drone(
          id: 14504000012,
          attributeCalculatorService: attrCalc,
        );

        await drone.fitting.updateSkills();

        var droneDps = drone.fitting.getValueForSlot(
          attribute: EveEchoesAttribute.optimalRange,
          index: 0,
          slot: SlotType.high,
        );

        expect(
          droneDps.toStringAsFixed(2),
          '16000.00',
        );

        var charData =
            'QlpoOTFBWSZTWcoGNHEABuHfgHAAEAZ/8AAsCAo/L58qQAIdbdmAhFMTaZQANNAAAAlT2pEm1QAA9QAAaET9FU0DQaDRoBhNMgIlEaTE1T01PAp6jTaR+qbTSWFU6bN/b8+wqUFUgA6979PMIKpBV4JBQcLnUNWpog5LF1uIUEBCZGCmMA0EYpWILUR410xjQm6qTXdpMFOcDjXFVV73uXvm7fK5d2N6KnCvfFVTYPegKpQc88s7i66taSsKSklIAgCCBwKThJpMhNMIGNwgBiLt6bxlJEOixYMobBIGrsW0B1IxyrSlKpJMyEVWMVdg0Lc1i3fBCzbJMsTIxylpUpShcQmxU4TQccEwTCSSbCBZAs2CwRhjTEvFLxVOEELgtJG1hLIF4rcXp6bt+69vjJCTP8VSpJJx4Va7RQ94AuH3AAeYqkgqnn59Ovzu8b+e3SvH2+3x7iqc8+njr15dOYqmoqmPbT+Iql2vPUFU/3IVTaiqbPPFFUryur2/X19WwwBVO2hptFUz/fhfMFE1e8+GlApNalaQo1JSQZKpJTLQKglQpJKPuF4SMooGQhGkom//F3JFOFCQygY0cQ==';
        var char = Character.fromQrCodeData(charData);
        var skills = char.learntSkills;

        await drone.fitting.updateSkills(skills: skills);

        droneDps = drone.fitting.getValueForSlot(
          attribute: EveEchoesAttribute.optimalRange,
          index: 0,
          slot: SlotType.high,
        );

        expect(
          droneDps.toStringAsFixed(2),
          '19840.00',
        );
      });
    });

    /// Adaptive Invulnerability Fields are subject to the
    /// stacking penalty
    group('Non-Stackable Modifiers', () {
      late FittingSimulator fitting;

      // Extract required items, and create fitting
      // Fitting:
      // Ship: Probe Covert Ops 10100000217
      // Low Slots:
      //  - 2x MK5 Adaptive Invulnerability Field 11313400006
      //  - 1x MK7 Adaptive Invulnerability Field 11313400008
      // Skills:
      // - Shield Hardening: Lv 5
      // - Frigate Defense Upgrade: Lv 5
      // 33 Total Implant Levels
      setUpAll(() async {
        var ship = await itemRepo.ship(id: 10100000217);
        expect(ship, isNotNull, reason: 'Cannot find Probe Covert Ops item');
        expect(ship.categoryId == EveEchoesCategory.ships.categoryId, true,
            reason: 'Item is not a ship');
        fitting = await FittingSimulator.fromShipLoadout(
          pilot: Character.empty,
          attributeCalculatorService: attrCalc,
          itemRepository: itemRepo,
          ship: ship,
          loadout: ShipFittingLoadout.fromShip(ship.itemId,
              await itemRepo.getShipLoadoutDefinition(ship.itemId)),
        );

        var invulFieldMk5 = await itemRepo.module(id: 11313400006);
        expect(
          invulFieldMk5,
          isNotNull,
          reason: 'Cannot find MK5 Adaptive Invulnerability Field item',
        );
        var invulFieldMk7 = await itemRepo.module(id: 11313400008);
        expect(
          invulFieldMk7,
          isNotNull,
          reason: 'Cannot find MK7 Adaptive Invulnerability Field item',
        );
        fitting.fitItem(
          invulFieldMk5,
          slot: SlotType.low,
          index: 0,
          notify: false,
        );
        fitting.fitItem(
          invulFieldMk5,
          slot: SlotType.low,
          index: 1,
          notify: false,
        );
        fitting.fitItem(
          invulFieldMk7,
          slot: SlotType.low,
          index: 2,
          notify: false,
        );
        var skills = [
          LearnedSkill(
            skillId: Skills.ShieldHardening,
            skillLevel: 5,
          ),
          LearnedSkill(
            skillId: Skills.FrigateDefenseUpgrade,
            skillLevel: 5,
          ),
        ];
        fitting.setTotalImplantLevels(33);
        await fitting.updateSkills(skills: skills);
      });

      setHardeners(bool mk5A, bool mk5B, bool mk7A) async {
        var waiter = waitForNextNotification(fitting);
        fitting.setModuleState(
          mk5A ? ModuleState.active : ModuleState.inactive,
          slot: SlotType.low,
          index: 0,
        );
        await waiter;
        waiter = waitForNextNotification(fitting);
        fitting.setModuleState(
          mk5B ? ModuleState.active : ModuleState.inactive,
          slot: SlotType.low,
          index: 1,
        );
        await waiter;
        waiter = waitForNextNotification(fitting);
        fitting.setModuleState(
          mk7A ? ModuleState.active : ModuleState.inactive,
          slot: SlotType.low,
          index: 2,
        );
        await waiter;
      }

      expectValues({
        required String shieldRes,
        required String shieldPoints,
        required String shieldEhp,
        required String weakestEhp,
      }) {
        var actShieldResist = fitting.getValueForItem(
            attribute: EveEchoesAttribute.shieldEmDamageResonance,
            item: fitting.ship);
        var actShieldPoints = fitting.getValueForItem(
            attribute: EveEchoesAttribute.shieldCapacity, item: fitting.ship);
        var actShieldEhp = fitting.calculateEHPForAttribute(
            hpAttribute: EveEchoesAttribute.shieldCapacity,
            damagePattern: FittingPattern.uniform);
        var actDefense = fitting.calculateWeakestEHP();
        expect(shieldRes, actShieldResist.toStringAsFixed(2));
        expect(shieldPoints, actShieldPoints.toStringAsFixed(0));
        expect(shieldEhp, actShieldEhp.toStringAsFixed(0));
        expect(weakestEhp, actDefense.toStringAsFixed(0));
      }

      test('No Hardeners on', () async {
        // Turn off all invulnerability fields
        await setHardeners(false, false, false);
        expectValues(
          shieldRes: "0.90",
          shieldPoints: "692",
          shieldEhp: "989",
          weakestEhp: "2284");
      });

      test('One MK5 Hardener', () async {
        await setHardeners(true, false, false);
        expectValues(
            shieldRes: "0.71",
            shieldPoints: "692",
            shieldEhp: "1261",
            weakestEhp: "2496");
      });

      test('Two MK5 Hardeners', () async {
        await setHardeners(true, true, false);
        expectValues(
            shieldRes: "0.57",
            shieldPoints: "692",
            shieldEhp: "1554",
            weakestEhp: "2723");
      });

      test('One MK7 Hardener', () async {
        await setHardeners(false, false, true);
        expectValues(
            shieldRes: "0.69",
            shieldPoints: "692",
            shieldEhp: "1294",
            weakestEhp: "2521");
      });

      test('One MK5 + One MK7 Hardener', () async {
        await setHardeners(true, false, true);
        expectValues(
            shieldRes: "0.56",
            shieldPoints: "692",
            shieldEhp: "1594",
            weakestEhp: "2754");
      });

      test('Two MK5 + One MK7 Hardener', () async {
        await setHardeners(true, true, true);
        expectValues(
            shieldRes: "0.49",
            shieldPoints: "692",
            shieldEhp: "1818",
            weakestEhp: "2929");
      });
    });

    ///
    /// These tests will create a Fitting consisting of:
    /// Ship: Caracal 10300000108
    /// High Slot: 1x 'Challenger Medium Torpedo Launcher 11017000012
    /// Low Slot: 2x Full Duplext BCS 11516000012
    /// Rig: 1x Loading Accelerator Prototype 11706050001
    ///
    /// Skills:                               IDs
    /// - Med Missile Operation: Lv 4     49440000007
    /// - Adv Med Missile Operation: Lv 4 49440000008
    /// - Med Missile Upgrade: Lv 4       49440000010
    /// - Adv Med Missile Upgrade: Lv 3   49440000011
    /// - Crusier Comand: Lv 4            49110000007
    ///
    /// Expected Activation time (Attr 430):  ~4.98 seconds
    group('Caracal fitting >', () {
      late FittingSimulator fitting;

      // Extract required items, and create fitting
      setUpAll(() async {
        var ship = await itemRepo.ship(id: 10300000108);
        expect(ship, isNotNull, reason: 'Cannot find Caracal item');
        expect(ship.categoryId == EveEchoesCategory.ships.categoryId, true,
            reason: 'Item is not a ship');

        var skills = [
          LearnedSkill(
            skillId: Skills.CruiserCommand,
            skillLevel: 4,
          ),
          LearnedSkill(
            skillId: Skills.MediumMissileTorpedoOperation,
            skillLevel: 4,
          ),
          LearnedSkill(
            skillId: Skills.AdvancedMediumMissileTorpedoOperation,
            skillLevel: 4,
          ),
          LearnedSkill(
            skillId: Skills.MediumMissileTorpedoUpgrade,
            skillLevel: 4,
          ),
          LearnedSkill(
            skillId: Skills.AdvancedMediumMissileTorpedoUpgrade,
            skillLevel: 3,
          ),
        ];

        fitting = await FittingSimulator.fromShipLoadout(
          pilot: Character.empty,
          attributeCalculatorService: attrCalc,
          itemRepository: itemRepo,
          ship: ship,
          loadout: ShipFittingLoadout.fromShip(ship.itemId,
              await itemRepo.getShipLoadoutDefinition(ship.itemId)),
        );

        var torpedo = await itemRepo.module(id: 11017000012);
        expect(
          torpedo,
          isNotNull,
          reason: 'Cannot find Challenger Medium Torpedo Launcher item',
        );

        var bcs = await itemRepo.module(id: 11516000012);
        expect(
          bcs,
          isNotNull,
          reason: 'Cannot find Full Duplex BCU item',
        );

        var loadingRig = await itemRepo.module(id: 11706050001);
        expect(
          loadingRig,
          isNotNull,
          reason: 'Cannot find Loading Rig item',
        );

        var heatingRig = await itemRepo.module(id: 11706010001);
        expect(
          loadingRig,
          isNotNull,
          reason: 'Cannot find Warhead Heating Catalyst Prototype item',
        );

        fitting.fitItem(torpedo, slot: SlotType.high, index: 0, notify: false);
        fitting.fitItem(torpedo, slot: SlotType.high, index: 1, notify: false);
        fitting.fitItem(torpedo, slot: SlotType.high, index: 2, notify: false);
        fitting.fitItem(torpedo, slot: SlotType.high, index: 3, notify: false);

        fitting.fitItem(
          bcs,
          slot: SlotType.low,
          index: 0,
          notify: false,
          state: ModuleState.inactive,
        );
        fitting.fitItem(
          bcs,
          slot: SlotType.low,
          index: 1,
          notify: false,
          state: ModuleState.inactive,
        );

        fitting.fitItem(loadingRig,
            slot: SlotType.combatRig, index: 0, notify: false);
        fitting.fitItem(heatingRig,
            slot: SlotType.combatRig, index: 1, notify: false);

        // Calculate fittings
        await fitting.updateSkills(skills: skills);
      });

      group('Challenge Med Torpedo >', () {
        test('Activation Time is 4.85s', () async {
          // Extract final 'display' value for Activation Time attribute (ID: 430)
          var attributeDefinition = await itemRepo.attributeWithId(
              id: EveEchoesAttribute.activationTime.attributeId);

          expect(attributeDefinition, isNotNull);

          var value = fitting.getValueForSlot(
            attribute: EveEchoesAttribute.activationTime,
            slot: SlotType.high,
            index: 0,
          );

          value = attributeDefinition!.calculatedValue(fromValue: value);

          expect(
            value.toStringAsFixed(2),
            '4.85',
          );
        });

        test('Calc DPS is 107.97', () async {
          var dps = await fitting.calculateDpsForSlotIndex(
            slot: SlotType.high,
            index: 0,
          );

          expect(
            dps.toStringAsFixed(2),
            '107.97',
          );
        });

        test('Damages are 131.02', () async {
          // Damage mod
          var value = fitting.getValueForSlot(
            attribute: EveEchoesAttribute.damageMultiplier,
            slot: SlotType.high,
            index: 0,
          );

          expect(
            value,
            3.743557512292552,
          );

          // EM damage
          var emDamage = fitting.getValueForSlot(
            attribute: EveEchoesAttribute.emDamage,
            slot: SlotType.high,
            index: 0,
          );

          expect(
            emDamage.toStringAsFixed(2),
            '131.02',
          );

          // Thermal damage
          var thermDamage = fitting.getValueForSlot(
            attribute: EveEchoesAttribute.thermalDamage,
            slot: SlotType.high,
            index: 0,
          );

          expect(
            thermDamage.toStringAsFixed(2),
            '131.02',
          );

          // Kinetic damage
          var kinDamage = fitting.getValueForSlot(
            attribute: EveEchoesAttribute.kineticDamage,
            slot: SlotType.high,
            index: 0,
          );

          expect(
            kinDamage.toStringAsFixed(2),
            '131.02',
          );

          // Explosive damage
          var expDamage = fitting.getValueForSlot(
            attribute: EveEchoesAttribute.explosiveDamage,
            slot: SlotType.high,
            index: 0,
          );

          expect(
            expDamage.toStringAsFixed(2),
            '131.02',
          );
        });
      });
    });

    group('Stabber fitting >', () {
      late FittingSimulator fitting;

      // Extract required items, and create fitting
      setUpAll(() async {
        var ship = await itemRepo.ship(id: 10300000208);
        expect(ship, isNotNull, reason: 'Cannot find Stabber item');
        expect(ship.categoryId == EveEchoesCategory.ships.categoryId, true,
            reason: 'Item is not a ship');

        var charData =
            'QlpoOTFBWSZTWdnh5wQABlRfgDAAUAZ/8AAkCAo/b50qQAH9lEadhlQAMhpoAANNANMRCKGnpqHlBkAAGnqUARgmIDIZGjAiSmgRpMgyBoZAZMFRP7218ePIUIqJEB/OB07CKiRURwGuu3bsyZPchxFMOyEm1pQZdLbSpvLtNmi0iU2WTezdU6pCpwklvduKwF/CIEDXIekVEsPflcKiXZ3Vs0koqBJIhV2q8tJKIIKCBQJIUFUQiSWCQpSaISmpLfHeiSBBIjcRLsBwQQQBDeNMiW5SaBavGkAeCQBiAsTmATAxec6nKumZTNTJc5xmYMCOWnPLAs1VatlrSWkKoyHZyzBDTsBkwHAR3QvEALF8y7cQwA0lQDEcTCWLBWJaVEJctFQpqyCGMFv1c96Ap5iohz3RF8yG4B1T62bkkEWJW21UnxJBHRJBCVyM8Kon0KiVn3KiQVEv3AClbb7ddvW/C8VE32zVE18Pt6RQTw90kkkkCRk8qpJ3ScEwMMDAwCdwWjvAwCQgEeoPvxdyRThQkNnh5wQ=';
        var char = Character.fromQrCodeData(charData);
        var skills = char.learntSkills;

        fitting = await FittingSimulator.fromShipLoadout(
          pilot: Character.empty,
          attributeCalculatorService: attrCalc,
          itemRepository: itemRepo,
          ship: ship,
          loadout: ShipFittingLoadout.fromShip(ship.itemId,
              (await itemRepo.getShipLoadoutDefinition(ship.itemId))),
        );

        var weapon = await itemRepo.module(id: 11004610024);
        expect(
          weapon,
          isNotNull,
          reason: 'Cannot find Gistum C-Type Med Strike Cannon',
        );

        var trackingComp = await itemRepo.module(id: 11322000012);
        expect(
          trackingComp,
          isNotNull,
          reason: 'Cannot find Marketeer tracking comp',
        );

        var gyro = await itemRepo.module(id: 11501000021);
        expect(
          gyro,
          isNotNull,
          reason: 'Cannot find Rebirth gyro',
        );

        var loadingRig = await itemRepo.module(id: 11704000002);
        expect(
          loadingRig,
          isNotNull,
          reason: 'Cannot find Loading Rig item',
        );

        var heatingRig = await itemRepo.module(id: 11704020002);
        expect(
          loadingRig,
          isNotNull,
          reason: 'Cannot find Warhead Heating Catalyst Prototype item',
        );

        var pgRig = await itemRepo.module(id: 11711020001);
        expect(
          loadingRig,
          isNotNull,
          reason: 'Cannot find Auxiliary Energy Router Prototype item',
        );

        fitting.fitItem(weapon, slot: SlotType.high, index: 0, notify: false);
        fitting.fitItem(weapon, slot: SlotType.high, index: 1, notify: false);
        fitting.fitItem(weapon, slot: SlotType.high, index: 2, notify: false);
        fitting.fitItem(weapon, slot: SlotType.high, index: 3, notify: false);

        fitting.fitItem(trackingComp,
            slot: SlotType.low, index: 0, notify: false);
        // fittut.fitItem(trackingComp, slot: SlotType.low, index: 1, notify: false);
        fitting.fitItem(gyro, slot: SlotType.low, index: 2, notify: false);
        fitting.fitItem(gyro, slot: SlotType.low, index: 3, notify: false);

        fitting.fitItem(loadingRig,
            slot: SlotType.combatRig, index: 0, notify: false);
        fitting.fitItem(heatingRig,
            slot: SlotType.combatRig, index: 1, notify: false);

        fitting.fitItem(pgRig,
            slot: SlotType.engineeringRig, index: 0, notify: false);

        fitting.setModuleState(
          ModuleState.inactive,
          slot: SlotType.low,
          index: 0,
        );
        fitting.setModuleState(
          ModuleState.inactive,
          slot: SlotType.low,
          index: 2,
        );
        fitting.setModuleState(
          ModuleState.inactive,
          slot: SlotType.low,
          index: 3,
        );

        // Calculate fittings
        await fitting.updateSkills(skills: skills);
      });

      test('Powergrid Usage', () async {
        var powerGrid = fitting.calculatePowerGridUtilisation();

        expect(
          (powerGrid * 100).toStringAsFixed(2),
          '98.36',
        );
      });

      test('Flight Velocity is 372.06', () async {
        var speed = fitting.getValueForItem(
          attribute: EveEchoesAttribute.flightVelocity,
          item: fitting.ship,
        );

        expect(
          speed.toStringAsFixed(2),
          '372.06',
        );
      });

      group('Gistum C-Type Med Strike Cannon >', () {
        test('Activation Time is 7.99s', () async {
          // Extract final 'display' value for Activation Time attribute (ID: 430)
          var attributeDefinition = await itemRepo.attributeWithId(
              id: EveEchoesAttribute.activationTime.attributeId);
          var value = fitting.getValueForSlot(
            attribute: EveEchoesAttribute.activationTime,
            slot: SlotType.high,
            index: 0,
          );

          expect(attributeDefinition, isNotNull);
          value = attributeDefinition!.calculatedValue(fromValue: value);

          expect(
            value.toStringAsFixed(2),
            '7.99',
          );
        });

        test('Calc DPS is 82.97', () async {
          var dps = await fitting.calculateDpsForSlotIndex(
            slot: SlotType.high,
            index: 0,
          );

          expect(
            dps.toStringAsFixed(2),
            '82.97',
          );
        });

        test('Damages are correct 0/247/168/247', () async {
          // Damage mod
          var value = fitting.getValueForSlot(
            attribute: EveEchoesAttribute.damageMultiplier,
            slot: SlotType.high,
            index: 0,
          );

          expect(
            value,
            9.890154399064471,
          );

          // EM damage
          var emDamage = fitting.getValueForSlot(
            attribute: EveEchoesAttribute.emDamage,
            slot: SlotType.high,
            index: 0,
          );

          expect(
            emDamage.toStringAsFixed(0),
            '0',
          );

          // Thermal damage
          var thermDamage = fitting.getValueForSlot(
            attribute: EveEchoesAttribute.thermalDamage,
            slot: SlotType.high,
            index: 0,
          );

          expect(
            thermDamage.toStringAsFixed(0),
            '247',
          );

          // Kinetic damage
          var kinDamage = fitting.getValueForSlot(
            attribute: EveEchoesAttribute.kineticDamage,
            slot: SlotType.high,
            index: 0,
          );

          expect(
            kinDamage.toStringAsFixed(0),
            '168',
          );

          // Explosive damage
          var expDamage = fitting.getValueForSlot(
            attribute: EveEchoesAttribute.explosiveDamage,
            slot: SlotType.high,
            index: 0,
          );

          expect(
            expDamage.toStringAsFixed(0),
            '247',
          );
        });
      });
    });

    group('Kryos fitting >', () {
      late FittingSimulator fitting;

      // Extract required items, and create fitting
      setUpAll(() async {
        var ship = await itemRepo.ship(id: 10600000401);
        expect(ship, isNotNull, reason: 'Cannot find Kryos item');
        expect(ship.categoryId == EveEchoesCategory.ships.categoryId, true,
            reason: 'Item is not a ship');

        var skills = [
          LearnedSkill(skillId: 49110000016, skillLevel: 4),
          LearnedSkill(skillId: 49110000017, skillLevel: 3),
        ];

        fitting = await FittingSimulator.fromShipLoadout(
          pilot: Character.empty,
          attributeCalculatorService: attrCalc,
          itemRepository: itemRepo,
          ship: ship,
          loadout: ShipFittingLoadout.fromShip(ship.itemId,
              await itemRepo.getShipLoadoutDefinition(ship.itemId)),
        );

        var cargoHoldRig = await itemRepo.module(id: 11710010001);
        expect(
          cargoHoldRig,
          isNotNull,
          reason: 'Cannot find cargo Hold Rig item',
        );

        fitting.fitItem(cargoHoldRig,
            slot: SlotType.combatRig, index: 0, notify: false);
        fitting.fitItem(cargoHoldRig,
            slot: SlotType.combatRig, index: 1, notify: false);

        // Calculate fittings
        await fitting.updateSkills(skills: skills);
      });

      test('Cargo hold is 3,600m3', () async {
        var attributeDefinition = await itemRepo.attributeWithId(
            id: EveEchoesAttribute.cargoHoldCapacity.attributeId);
        var value = fitting.getValueForItem(
          item: fitting.ship,
          attribute: EveEchoesAttribute.cargoHoldCapacity,
        );

        expect(attributeDefinition, isNotNull);
        value = attributeDefinition!.calculatedValue(fromValue: value);

        expect(
          value,
          3600,
        );
      });

      test('Mineral hold is 46,000m3', () async {
        var attributeDefinition = await itemRepo.attributeWithId(
            id: EveEchoesAttribute.mineralHoldCapacity.attributeId);
        var value = fitting.getValueForItem(
          item: fitting.ship,
          attribute: EveEchoesAttribute.mineralHoldCapacity,
        );

        expect(attributeDefinition, isNotNull);
        value = attributeDefinition!.calculatedValue(fromValue: value);

        expect(
          value,
          46000,
        );
      });

      test('Defence EHP is ~7182', () async {
        var value = fitting.calculateWeakestEHP();
        expect(
          value.toStringAsFixed(2),
          '7182.34',
        );
      });
    });

    group('Atron fitting >', () {
      late FittingSimulator fitting;

      final skills = [
        LearnedSkill(skillId: Skills.FrigateCommand, skillLevel: 5),
        LearnedSkill(skillId: Skills.AdvancedFrigateCommand, skillLevel: 4),
        LearnedSkill(skillId: Skills.Afterburner, skillLevel: 4),
        LearnedSkill(skillId: Skills.AdvancedAfterburner, skillLevel: 4),
        LearnedSkill(skillId: Skills.ShieldOperation, skillLevel: 4),
        LearnedSkill(skillId: Skills.AdvancedShieldOperation, skillLevel: 4),
        LearnedSkill(skillId: Skills.FrigateEngineering, skillLevel: 5),
        LearnedSkill(skillId: Skills.AdvancedFrigateEngineering, skillLevel: 3),
        LearnedSkill(skillId: Skills.ElectronicWarfare, skillLevel: 4),
        LearnedSkill(skillId: Skills.SignalDisruption, skillLevel: 3),
        LearnedSkill(skillId: Skills.SmallRailgunOperation, skillLevel: 4),
        LearnedSkill(
            skillId: Skills.AdvancedSmallRailgunOperation, skillLevel: 3),
        LearnedSkill(skillId: Skills.SmallRailgunUpgrade, skillLevel: 4),
      ];

      // Extract required items, and create fitting
      setUpAll(() async {
        var ship = await itemRepo.ship(id: 10100000405);
        expect(ship, isNotNull, reason: 'Cannot find Atron item');
        expect(ship.categoryId == EveEchoesCategory.ships.categoryId, true,
            reason: 'Item is not a ship');

        fitting = await FittingSimulator.fromShipLoadout(
          pilot: Character.empty,
          attributeCalculatorService: attrCalc,
          itemRepository: itemRepo,
          ship: ship,
          loadout: ShipFittingLoadout.fromShip(ship.itemId,
              await itemRepo.getShipLoadoutDefinition(ship.itemId)),
        );

        var weapon = await itemRepo.module(id: 11000520021);
        expect(
          weapon,
          isNotNull,
          reason: 'Cannot find Quafe Small Snubnosed Railgun',
        );

        var scram = await itemRepo.module(id: 11347000006);
        expect(
          scram,
          isNotNull,
          reason: 'Cannot find Mk5 Warp Scrambler',
        );

        var shieldBooster = await itemRepo.module(id: 11302000012);
        expect(
          shieldBooster,
          isNotNull,
          reason: 'Cannot find Settler Small Shield Booster',
        );

        var afterBurner = await itemRepo.module(id: 11304500012);
        expect(
          afterBurner,
          isNotNull,
          reason: 'Cannot find Smuggler Small Afterburner gyro',
        );

        fitting.fitItem(weapon, slot: SlotType.high, index: 0, notify: false);
        fitting.fitItem(weapon, slot: SlotType.high, index: 1, notify: false);

        fitting.fitItem(scram, slot: SlotType.mid, index: 0, notify: false);

        fitting.fitItem(shieldBooster,
            slot: SlotType.low, index: 0, notify: false);
        fitting.fitItem(afterBurner,
            slot: SlotType.low, index: 1, notify: false);

        // Calculate fittings
        await fitting.updateSkills(skills: skills);
      });

      test('Afterburner activation time is 8.836s', () {
        // Damage mod
        var value = fitting.getValueForSlot(
          attribute: EveEchoesAttribute.activationTime,
          slot: SlotType.low,
          index: 1,
        );

        expect(value, 8836);
      });

      test('Shield booster activation cost is 29.58', () {
        // Damage mod
        var value = fitting.getValueForSlot(
          attribute: EveEchoesAttribute.activationCost,
          slot: SlotType.low,
          index: 0,
        );

        expect(value.toStringAsFixed(2), '29.58');
      });

      test('Capacitor lasts 1m 07 secs', () async {
        var value = await fitting.capacitorSimulation();
        expect(
          value.ttl.inSeconds,
          67,
        );
      });

      test('Mag Stab Unfit/Cold/Hot', () async {
        var magStab = await itemRepo.module(id: 11510000012);
        expect(
          magStab,
          isNotNull,
          reason: 'Cannot find Basic Magnetic Field Stabalizer',
        );

        var dps = fitting.calculateTotalDps();
        expect(dps.toStringAsFixed(2), '119.57');

        fitting.fitItem(magStab, slot: SlotType.low, index: 0, notify: false);
        // Not needed in app running, but need to wait for testing
        await fitting.updateSkills(skills: skills);
        dps = fitting.calculateTotalDps();
        expect(dps.toStringAsFixed(2), '158.07');

        fitting.setModuleState(ModuleState.inactive,
            slot: SlotType.low, index: 0);
        // Not needed in app running, but need to wait for testing
        await fitting.updateSkills(skills: skills);
        dps = fitting.calculateTotalDps();
        expect(dps.toStringAsFixed(2), '140.20');
      });
    });
    group('Thorax fitting >', () {
      late FittingSimulator fitting;

      final skills = [
        LearnedSkill(skillId: Skills.CruiserCommand, skillLevel: 4),
        LearnedSkill(skillId: Skills.CruiserEngineering, skillLevel: 4),
        LearnedSkill(skillId: Skills.AdvancedCruiserEngineering, skillLevel: 4),
        //
        LearnedSkill(skillId: Skills.Afterburner, skillLevel: 4),
        LearnedSkill(skillId: Skills.AdvancedAfterburner, skillLevel: 4),
        //
        LearnedSkill(skillId: Skills.ArmorOperation, skillLevel: 4),
        LearnedSkill(skillId: Skills.AdvancedArmorOperation, skillLevel: 3),
        LearnedSkill(skillId: Skills.ArmorHardening, skillLevel: 5),
        LearnedSkill(skillId: Skills.AdvancedArmorHardening, skillLevel: 3),
        //
        LearnedSkill(skillId: Skills.MediumRailgunOperation, skillLevel: 4),
        LearnedSkill(
            skillId: Skills.AdvancedMediumRailgunOperation, skillLevel: 3),
        LearnedSkill(skillId: Skills.MediumRailgunUpgrade, skillLevel: 4),
        LearnedSkill(
            skillId: Skills.AdvancedMediumRailgunUpgrade, skillLevel: 3),
      ];

      // Extract required items, and create fitting
      setUpAll(() async {
        var ship = await itemRepo.ship(id: 10300000410);
        expect(ship, isNotNull, reason: 'Cannot find Thorax item');
        expect(ship.categoryId == EveEchoesCategory.ships.categoryId, true,
            reason: 'Item is not a ship');

        fitting = await FittingSimulator.fromShipLoadout(
          pilot: Character.empty,
          attributeCalculatorService: attrCalc,
          itemRepository: itemRepo,
          ship: ship,
          loadout: ShipFittingLoadout.fromShip(ship.itemId,
              await itemRepo.getShipLoadoutDefinition(ship.itemId)),
        );

        var weapon = await itemRepo.module(id: 11000620013);
        expect(
          weapon,
          isNotNull,
          reason: 'Cannot find Fed Navy Medium Snubnosed Railgun',
        );

        var scram = await itemRepo.module(id: 11347000012);
        expect(
          scram,
          isNotNull,
          reason: 'Cannot find Interuptive Warp Scrambler',
        );

        var nos = await itemRepo.module(id: 11031100012);
        expect(
          nos,
          isNotNull,
          reason: 'Cannot find Upir Med Nos',
        );

        var magStab = await itemRepo.module(id: 11510000012);
        expect(
          magStab,
          isNotNull,
          reason: 'Cannot find Basic Magnetic Field Stabalizer',
        );

        var armHard = await itemRepo.module(id: 11513100012);
        expect(
          magStab,
          isNotNull,
          reason: 'Cannot find Basic Magnetic Field Stabalizer',
        );

        var afterBurner = await itemRepo.module(id: 11304600012);
        expect(
          afterBurner,
          isNotNull,
          reason: 'Cannot find Smuggler Med Afterburner gyro',
        );

        var armRep = await itemRepo.module(id: 11503100012);
        expect(
          afterBurner,
          isNotNull,
          reason: 'Cannot find Gorget Med Arm Rep',
        );

        var burstRig = await itemRepo.module(id: 11700030002);
        expect(
          burstRig,
          isNotNull,
          reason: 'Cannot find Railgun Burst Aerator I item',
        );

        fitting.fitItemIntoAll(weapon, slot: SlotType.high, notify: false);

        fitting.fitItem(scram, slot: SlotType.mid, index: 0, notify: false);
        fitting.fitItem(nos, slot: SlotType.mid, index: 1, notify: false);

        fitting.fitItem(magStab, slot: SlotType.low, index: 0, notify: false);
        fitting.fitItem(magStab, slot: SlotType.low, index: 1, notify: false);

        fitting.fitItem(armHard, slot: SlotType.low, index: 2, notify: false);
        fitting.fitItem(armRep, slot: SlotType.low, index: 3, notify: false);
        fitting.fitItem(afterBurner,
            slot: SlotType.low, index: 4, notify: false);

        fitting.fitItem(burstRig, slot: SlotType.combatRig, index: 0);
        fitting.fitItem(burstRig, slot: SlotType.combatRig, index: 1);

        // Calculate fittings
        await fitting.updateSkills(skills: skills);
      });
      group('Fed Nav Med Snub Rails >', () {
        test('Activation Time is 2.81s', () async {
          // Extract final 'display' value for Activation Time attribute (ID: 430)
          var attributeDefinition = await itemRepo.attributeWithId(
              id: EveEchoesAttribute.activationTime.attributeId);
          var value = fitting.getValueForSlot(
            attribute: EveEchoesAttribute.activationTime,
            slot: SlotType.high,
            index: 0,
          );

          expect(attributeDefinition, isNotNull);
          value = attributeDefinition!.calculatedValue(fromValue: value);

          expect(
            value.toStringAsFixed(2),
            '2.81',
          );
        });

        test('Calc DPS is 152', () async {
          var dps = await fitting.calculateDpsForSlotIndex(
            slot: SlotType.high,
            index: 0,
          );

          expect(
            dps.toStringAsFixed(2),
            '152.14',
          );
        });

        test('Damages are 0/162/265/0', () async {
          // Damage mod
          var value = fitting.getValueForSlot(
            attribute: EveEchoesAttribute.damageMultiplier,
            slot: SlotType.high,
            index: 0,
          );

          expect(
            value,
            7.373324435311049,
          );

          // EM damage
          var emDamage = fitting.getValueForSlot(
            attribute: EveEchoesAttribute.emDamage,
            slot: SlotType.high,
            index: 0,
          );

          expect(
            emDamage.toStringAsFixed(2),
            '0.00',
          );

          // Thermal damage
          var thermDamage = fitting.getValueForSlot(
            attribute: EveEchoesAttribute.thermalDamage,
            slot: SlotType.high,
            index: 0,
          );

          expect(
            thermDamage.toStringAsFixed(2),
            '162.21',
          );

          // Kinetic damage
          var kinDamage = fitting.getValueForSlot(
            attribute: EveEchoesAttribute.kineticDamage,
            slot: SlotType.high,
            index: 0,
          );

          expect(
            kinDamage.toStringAsFixed(2),
            '265.44',
          );

          // Explosive damage
          var expDamage = fitting.getValueForSlot(
            attribute: EveEchoesAttribute.explosiveDamage,
            slot: SlotType.high,
            index: 0,
          );

          expect(
            expDamage.toStringAsFixed(2),
            '0.00',
          );
        });
      });

      test('Capacitor lasts 328s', () async {
        var value = await fitting.capacitorSimulation();
        expect(
          value.ttl.inSeconds,
          328,
        );
      });
    });

    group('Executioner fitting >', () {
      late FittingSimulator fitting;

      final skills = [
        LearnedSkill(skillId: Skills.SmallRailgunOperation, skillLevel: 5),
        LearnedSkill(
            skillId: Skills.AdvancedSmallRailgunOperation, skillLevel: 4),
        LearnedSkill(skillId: Skills.SmallRailgunUpgrade, skillLevel: 5),
        LearnedSkill(
            skillId: Skills.AdvancedSmallRailgunUpgrade, skillLevel: 4),
      ];

      // Extract required items, and create fitting
      setUpAll(() async {
        var ship = await itemRepo.ship(id: 10100000309);
        expect(ship, isNotNull, reason: 'Cannot find Executioner item');
        expect(ship.categoryId == EveEchoesCategory.ships.categoryId, true,
            reason: 'Item is not a ship');

        fitting = await FittingSimulator.fromShipLoadout(
          pilot: Character.empty,
          attributeCalculatorService: attrCalc,
          itemRepository: itemRepo,
          ship: ship,
          loadout: ShipFittingLoadout.fromShip(ship.itemId,
              await itemRepo.getShipLoadoutDefinition(ship.itemId)),
        );

        var weapon = await itemRepo.module(id: 11000020008);
        expect(
          weapon,
          isNotNull,
          reason: 'Cannot find Mk7 Small Rifled Railgun',
        );

        var magStab = await itemRepo.module(id: 11510000010);
        expect(
          magStab,
          isNotNull,
          reason: 'Cannot find Mk9 Magnetic Field Stabilizer',
        );

        fitting.fitItem(weapon, slot: SlotType.high, index: 0, notify: false);

        fitting.fitItem(magStab, slot: SlotType.low, index: 0, notify: false);
        fitting.fitItem(magStab, slot: SlotType.low, index: 1, notify: false);

        // Calculate fittings
        await fitting.updateSkills(skills: skills);
      });

      // test('Both Weapon Mods Inactive 35.39', () {
      //   fitting.setModuleState(
      //     ModuleState.inactive,
      //     slot: SlotType.low,
      //     index: 0,
      //   );

      //   fitting.setModuleState(
      //     ModuleState.inactive,
      //     slot: SlotType.low,
      //     index: 1,
      //   );

      //   final value = fitting.calculateTotalDps();

      //   expect(value.toStringAsFixed(2), '35.39');
      // });

      test('Both Weapon Mods Active 55.05', () {
        fitting.setModuleState(
          ModuleState.inactive,
          slot: SlotType.low,
          index: 0,
        );

        fitting.setModuleState(
          ModuleState.inactive,
          slot: SlotType.low,
          index: 1,
        );

        fitting.setModuleState(
          ModuleState.active,
          slot: SlotType.low,
          index: 0,
        );

        fitting.setModuleState(
          ModuleState.active,
          slot: SlotType.low,
          index: 1,
        );

        // Damage mod
        final value = fitting.calculateTotalDps();

        expect(
          value.toStringAsFixed(2),
          '55.05',
        );
      });

      test('Only 1 Weapon Mod active 49.86 (slot 2)', () {
        fitting.setModuleState(
          ModuleState.inactive,
          slot: SlotType.low,
          index: 0,
        );

        fitting.setModuleState(
          ModuleState.active,
          slot: SlotType.low,
          index: 1,
        );

        final value = fitting.calculateTotalDps();

        expect(value.toStringAsFixed(2), '49.86');
      });

      test('Only 1 Weapon Mod active 49.86 (slot 1)', () {
        fitting.setModuleState(
          ModuleState.active,
          slot: SlotType.low,
          index: 0,
        );

        fitting.setModuleState(
          ModuleState.inactive,
          slot: SlotType.low,
          index: 1,
        );

        final value = fitting.calculateTotalDps();

        expect(value.toStringAsFixed(2), '49.86');
      });

      test('Both Weapon Mods Inactive 44.41', () {
        fitting.setModuleState(
          ModuleState.inactive,
          slot: SlotType.low,
          index: 0,
        );

        fitting.setModuleState(
          ModuleState.inactive,
          slot: SlotType.low,
          index: 1,
        );

        final value = fitting.calculateTotalDps();

        expect(value.toStringAsFixed(2), '44.41');
      });
    });

    group('Noctis fitting >', () {
      late FittingSimulator fitting;

      final skills = [
        LearnedSkill(skillId: 49520000007, skillLevel: 5),
        LearnedSkill(
            skillId: Skills.AdvancedIndustrialShipCommand, skillLevel: 5),
      ];

      // Extract required items, and create fitting
      setUpAll(() async {
        var ship = await itemRepo.ship(id: 10600001412);
        expect(ship, isNotNull, reason: 'Cannot find Noctis item');
        expect(ship.categoryId == EveEchoesCategory.ships.categoryId, true,
            reason: 'Item is not a ship');

        fitting = await FittingSimulator.fromShipLoadout(
          pilot: Character.empty,
          attributeCalculatorService: attrCalc,
          itemRepository: itemRepo,
          ship: ship,
          loadout: ShipFittingLoadout.fromShip(ship.itemId,
              await itemRepo.getShipLoadoutDefinition(ship.itemId)),
        );

        var salvager = await itemRepo.module(id: 11117010012);
        expect(
          salvager,
          isNotNull,
          reason: 'Cannot find Dust Auto Salvager',
        );

        fitting.fitItem(salvager, slot: SlotType.mid, index: 0, notify: false);

        // Calculate fittings
        await fitting.updateSkills(skills: skills);
      });

      test('Dust Auto Salvager Optimal Range is 37.80km', () async {
        // Extract final 'display' value for Activation Time attribute (ID: 430)
        var attributeDefinition = await itemRepo.attributeWithId(
            id: EveEchoesAttribute.optimalRange.attributeId);

        final salvagerRange = fitting.getValueForSlot(
          attribute: EveEchoesAttribute.optimalRange,
          slot: SlotType.mid,
          index: 0,
        );

        final value =
            attributeDefinition?.calculatedValue(fromValue: salvagerRange) ?? 0;

        expect(value.toStringAsFixed(2), '37.80');
      });
    });

    group('Implants >', () {
      late FittingSimulator fitting;

      final skills = <LearnedSkill>[
        // Shield Operation
        LearnedSkill(skillId: 49210000001, skillLevel: 5),
        // Small Drone Operation
        LearnedSkill(skillId: 49450000001, skillLevel: 4),
        // Small Drone Upgrade
        LearnedSkill(skillId: 49450000004, skillLevel: 4),
      ];

      // Extract required items, and create fitting
      setUpAll(() async {
        var ship = await itemRepo.ship(id: 10100000406);
        expect(ship, isNotNull, reason: 'Cannot find Tristan item');
        expect(ship.categoryId == EveEchoesCategory.ships.categoryId, true,
            reason: 'Item is not a ship');

        fitting = await FittingSimulator.fromShipLoadout(
          pilot: Character.empty,
          attributeCalculatorService: attrCalc,
          itemRepository: itemRepo,
          ship: ship,
          loadout: ShipFittingLoadout.fromShip(ship.itemId,
              await itemRepo.getShipLoadoutDefinition(ship.itemId)),
        );

        var booster = await itemRepo.module(id: 11302000014);
        expect(
          booster,
          isNotNull,
          reason: 'Cannot find Republic Fleet Small Shield Booster',
        );

        fitting.fitItem(booster, slot: SlotType.low, index: 0, notify: false);

        var drone = await itemRepo.drone(
          id: 14000030008,
          attributeCalculatorService: attrCalc,
        );

        fitting.fitItem(drone, slot: SlotType.drone, index: 0);

        // Set up implant
        //var implant = await itemRepo.implantWithId(id: 16008000004);
        final definition =
            await itemRepo.getImplantLoadoutDefinition(16008000004);

        final loadout = ImplantFittingLoadout.fromDefinition(
          16008000004,
          definition,
        );
        final handler = await ImplantHandler.fromImplantLoadout(
          implant: await itemRepo.implantModule(id: loadout.implantItemId),
          itemRepository: itemRepo,
          definition: definition,
          loadout: loadout,
        );
        handler.setLevel(15);
        bool succ = false;
        // Shield Booster Efficiency Optimization v1.0 (Level 5 GU)
        succ = handler.fitItem(await itemRepo.implantModule(id: 16500017011),
            slotIndex: 0);
        expect(succ, true,
            reason:
                'Failed to fit Shield Booster Efficiency Optimization v1.0 (Level 5 GU)');
        // Micro Thruster (Level 15 Branch)
        succ = handler.fitItem(await itemRepo.implantModule(id: 16300034004),
            slotIndex: 2);
        expect(succ, true,
            reason: 'Failed to fit Micro Thruster (Level 15 Branch)');

        succ = fitting.setImplant(handler);
        expect(succ, true, reason: 'Failed to set implant');
        // Deactivate primary skill (has no effect anyways but that may be changed in the future)
        fitting.setImplantModuleState(ModuleState.inactive,
            slotIndex: 0, implantSlotId: 0);
        // Calculate fittings
        await fitting.updateSkills(skills: skills);
      });

      test('Shield Booster Amount is 90.10', () async {
        var attributeDefinition = await itemRepo.attributeWithId(
            id: EveEchoesAttribute.shieldBoostAmount.attributeId);

        final amount = fitting.getValueForSlot(
          attribute: EveEchoesAttribute.shieldBoostAmount,
          slot: SlotType.low,
          index: 0,
        );

        final value =
            attributeDefinition?.calculatedValue(fromValue: amount) ?? 0;

        expect(value.toStringAsFixed(2), '90.10');
      });

      test('Drone Flight velocity is 5040 m/s', () async {
        var attributeDefinition = await itemRepo.attributeWithId(
            id: EveEchoesAttribute.flightVelocity.attributeId);

        final amount = fitting.getValueForSlot(
          attribute: EveEchoesAttribute.flightVelocity,
          slot: SlotType.drone,
          index: 0,
        );

        final value =
            attributeDefinition?.calculatedValue(fromValue: amount) ?? 0;

        expect(value.toStringAsFixed(0), '5040');
      });
    });

    group('AI Nanocore >', () {
      late FittingSimulator fitting;

      final skills = <LearnedSkill>[
        // Large Railgun Operation 555
        LearnedSkill(skillId: 49420000013, skillLevel: 5),
        LearnedSkill(skillId: 49420000014, skillLevel: 5),
        LearnedSkill(skillId: 49420000015, skillLevel: 5),
        // Large Railgun Upgrade 555
        LearnedSkill(skillId: 49420000016, skillLevel: 5),
        LearnedSkill(skillId: 49420000017, skillLevel: 5),
        LearnedSkill(skillId: 49420000018, skillLevel: 5),
        // Gunnery 400
        LearnedSkill(skillId: 49470000207, skillLevel: 4),
      ];

      // Extract required items, and create fitting
      setUpAll(() async {
        var ship = await itemRepo.ship(id: 10500000408);
        expect(ship, isNotNull,
            reason: 'Cannot find Megathron Navy Issue item');
        expect(ship.categoryId == EveEchoesCategory.ships.categoryId, true,
            reason: 'Item is not a ship');

        fitting = await FittingSimulator.fromShipLoadout(
          pilot: Character.empty,
          attributeCalculatorService: attrCalc,
          itemRepository: itemRepo,
          ship: ship,
          loadout: ShipFittingLoadout.fromShip(ship.itemId,
              await itemRepo.getShipLoadoutDefinition(ship.itemId)),
        );
        // Highslots
        var rail = await itemRepo.module(id: 11000220024);
        expect(
          rail,
          isNotNull,
          reason: 'Cannot find Core C-Type Large Rifled Railgun',
        );
        for (int i = 0; i < 7; i++) {
          fitting.fitItem(rail, slot: SlotType.high, index: i, notify: false);
        }
        // Lowslots: Corelum C-Type Magnetic Field Stabilizer
        var magStab = await itemRepo.module(id: 11510000024);
        for (int i = 0; i < 4; i++) {
          fitting.fitItem(magStab,
              slot: SlotType.low,
              index: i,
              state: ModuleState.inactive,
              notify: false);
        }
        //Rigs
        var burstAerator = await itemRepo.rig(id: 11700030008);

        fitting.fitItem(burstAerator,
            slot: SlotType.combatRig, index: 0, notify: false);
        fitting.fitItem(burstAerator,
            slot: SlotType.combatRig, index: 1, notify: false);
        fitting.fitItem(burstAerator,
            slot: SlotType.combatRig, index: 2, notify: false);

        // Create AI Nanocore, Thermomagnetic Storm II
        var aiCore = await itemRepo.nanocore(id: 81300400226);
        // +22.5% Large Railgun and Thermal Damage
        aiCore.mainAttribute.selectAttributeById(82000063005, 0);
        aiCore.secondMainAttribute!.selectAttributeById(82000063105, 0);
        // +8.66% Turrets Damage
        aiCore.trainableAttributes[0].selectAttributeById(82000061805, 9);
        // +10.08% Turrets Thermal Damage
        aiCore.trainableAttributes[2].selectAttributeById(82000062005, 8);
        fitting.fitItem(aiCore,
            slot: SlotType.nanocore, index: 0, notify: false);
        // Nanocore library
        // Large Railguns Damage Lvl. 4
        var gunDamageAffix =
            await itemRepo.nanocoreAffixWithId(itemId: 82100000604);
        // Large Railguns Activation Time Lvl. 4
        var gunTimeAffix =
            await itemRepo.nanocoreAffixWithId(itemId: 82100004204);
        fitting.fitNanocoreAffix(gunDamageAffix,
            index: 0, active: true, notify: false);
        fitting.fitNanocoreAffix(gunTimeAffix,
            index: 1, active: true, notify: false);
        // Calculate fittings
        await fitting.updateSkills(skills: skills);
      });

      test('Calc DPS is 4767.90', () async {
        var dps = fitting.calculateTotalDps();
        expect(
          dps.toStringAsFixed(2),
          '4767.90',
        );
      });
    });

    group('Astarte fitting >', () {
      late FittingSimulator fitting;

      final character = """
QlpoOTFBWSZTWThdSq4AGFrfgHAAUAZ/8CAkDQovL98KUAT+gOcQUUAcIIp4ZMqpoIMj0I00ANNCJ5lV
UYAAAAAAEmkSjRFNNAGQBkA0MNDIaZNAMQ000aGjAqVJqfomp6j0mJkDI09I9EPUtCI3YX7OHHpiIhWE
RUI0Y01f1SoiOI4ieIiOI4jkfZyv3c+3ursg/Axzyt547INvLwrZi83atRMWCZqkNswdygyZFRqDEiGU
FhthFE43lyxhm8pBHLFC3orNgs0ASnGPLt2EEdJOuVK3VVJFNtttuM1q28oDA22wlSlJa6MZWZpF2sxm
8wMa70sjKvLbMukDu4ks3VG3abmTOUTZWTeB2a1AUteTr1QVAmwNvQ5QOy7Mzd7VEczN8/KSQIc6+DAI
Q9vaHdOmKqitvhPPXcAIQ7c5vrm7bu5qbm4XKZlKjmZMJkzSybFYAjJMawBMZGOVMSsAVawBSEQVVRWx
GVBioxiDGIKQQG5SASyy26kssstjKIhq1dy3fXnBF3lcc5znB1rxa5zmnBV28vOc5ylV5cvOc5y2tnHn
N13lLaWmcw0dtW7uZttLd3NSe9APYekgEDcX3VT0tVEy1a3LXwl1N8JZz3TjFBYw7OdszMuXK2222S22
1pJJJJJNTQUAAAgAFAygAFpsigo9SE8YEsBDEFVEBVBQUUFUiwF7ev+7h4VW0t6zy5raVSrRnlmdET1Z
x74ZmY5lUhb23d3d1UA3lVVFJQoW3rzWs2NZNZu61qazMpOzMgGSwLCSlCGIL7Os8xtbavhwcEUtaNKi
3g+FVVUiqwnLbbaVVHxbbXfBCLAWNoSemSeA8eDWnbPBmiqjlNylq40pZ26DsqqqIoKiKqCqIqqqqqoX
qSCgQDoAhDWSHfruVbXbRVHq1Gaz2/DyEh4J9WeYBnY7sHqrFQtU9qVXyulxrlojU9Cnknb4+3ruKdFp
3yqVozrHTongDkx29rcxVUVKd/w7iEaahtwiERj5QIjdny0crNvrv7ttvW/Vh29OYRHXZbv2QRGWUERf
wpfzgRFMPoERlpCIvgiLqgiP27PXAiLKWa7KV5+m7x7NK0ERd84amdNFdIIj26oP+YSSB+Mk94/sKfGm
JCRQuFIGJYlQFhBYBKFoBUKyYwKrJFFFh8KUk1bqXCFYjCHy/8XckU4UJA4XUquA"""
          .replaceAll("\n", "");

      setUpAll(() async {
        final Character pilot = Character.fromQrCodeData(character);
        var ship = await itemRepo.ship(id: 10706000301);
        expect(ship, isNotNull, reason: 'Cannot find Astarte item');
        expect(ship.categoryId == EveEchoesCategory.ships.categoryId, true,
            reason: 'Item is not a ship');

        fitting = await FittingSimulator.fromShipLoadout(
          pilot: pilot,
          attributeCalculatorService: attrCalc,
          itemRepository: itemRepo,
          ship: ship,
          loadout: ShipFittingLoadout.fromShip(ship.itemId,
              await itemRepo.getShipLoadoutDefinition(ship.itemId)),
        );
        // Lowslots
        var fireControl = await itemRepo.module(id: 11519200010);
        expect(
          fireControl,
          isNotNull,
          reason: 'Cannot find Prototype General Fire-control System',
        );
        fitting.fitItem(fireControl,
            slot: SlotType.low,
            index: 0,
            notify: false,
            state: ModuleState.inactive);
        // Combat rigs
        var burstAerator = await itemRepo.rig(id: 11719150006);
        expect(
          burstAerator,
          isNotNull,
          reason: 'Cannot find LWS Burst Aerator I',
        );
        fitting.fitItem(burstAerator,
            slot: SlotType.combatRig, index: 0, notify: false);
        fitting.fitItem(burstAerator,
            slot: SlotType.combatRig, index: 1, notify: false);
        fitting.fitItem(burstAerator,
            slot: SlotType.combatRig, index: 2, notify: false);
        // Hangar modules
        var monoLWSMod = await itemRepo.rig(id: 11727010011);
        expect(
          monoLWSMod,
          isNotNull,
          reason: 'Cannot find Mono LWS Hangar Modification I',
        );
        fitting.fitItem(monoLWSMod,
            slot: SlotType.hangarRigSlots, index: 0, notify: false);
        // Lightweight Frigates
        var frigate = await itemRepo.drone(
            id: 14700010410, attributeCalculatorService: attrCalc);
        expect(
          frigate,
          isNotNull,
          reason: 'Cannot find Lightweight Atron',
        );
        fitting.fitItem(frigate,
            slot: SlotType.lightFFSlot, index: 0, notify: false);
        // Lightweight Destroyers
        var destroyer = await itemRepo.drone(
            id: 14710010410, attributeCalculatorService: attrCalc);
        expect(
          destroyer,
          isNotNull,
          reason: 'Cannot find Lightweight Catalyst',
        );
        fitting.fitItem(destroyer,
            slot: SlotType.lightDDSlot, index: 0, notify: true);
      });

      test('Total DPS is 4073.72', () async {
        var dps = fitting.calculateTotalDps();
        expect(dps, closeTo(4073.72, 0.02));
      });

      test('Lightweight Catalyst', () async {
        var value = await fitting.calculateValueForSlot(
          attribute: EveEchoesAttribute.activationTime,
          slot: SlotType.lightDDSlot,
          index: 0,
          droneSlot: SlotType.high,
        );
        expect(value, closeTo(2.90, 0.01),
            reason: 'Activation Time: Expected 2.90, got $value');

        value = await fitting.calculateValueForSlot(
          attribute: EveEchoesAttribute.optimalRange,
          slot: SlotType.lightDDSlot,
          index: 0,
          droneSlot: SlotType.high,
        );
        expect(value, closeTo(17.16, 0.01),
            reason: 'Optimal Range: Expected 17.16, got $value');

        value = await fitting.calculateValueForSlot(
          attribute: EveEchoesAttribute.accuracyFalloff,
          slot: SlotType.lightDDSlot,
          index: 0,
          droneSlot: SlotType.high,
        );
        expect(value, closeTo(10.56, 0.01),
            reason: 'Accuracy Falloff: Expected 10.56, got $value');

        value = await fitting.calculateValueForSlot(
          attribute: EveEchoesAttribute.trackingSpeed,
          slot: SlotType.lightDDSlot,
          index: 0,
          droneSlot: SlotType.high,
        );
        expect(value, closeTo(1220, 0.6),
            reason: 'Tracking Speed: Expected 1220, got $value');

        value = await fitting.calculateValueForSlot(
          attribute: EveEchoesAttribute.thermalDamage,
          slot: SlotType.lightDDSlot,
          index: 0,
          droneSlot: SlotType.high,
        );
        expect(value, closeTo(1304, 0.6),
            reason: 'Thermal Damage: Expected 1304, got $value');
        value = fitting.calculateTotalAlphaStrike(
            damageType: EveEchoesAttribute.thermalDamage);
        expect(value, closeTo(4720.84, 0.1),
            reason: 'Thermal Alpha Strike: Expected 4720.84, got $value');

        value = await fitting.calculateValueForSlot(
          attribute: EveEchoesAttribute.kineticDamage,
          slot: SlotType.lightDDSlot,
          index: 0,
          droneSlot: SlotType.high,
        );
        expect(value, closeTo(1956, 0.6),
            reason: 'Kinetic Damage: Expected 1956, got $value');
        value = fitting.calculateTotalAlphaStrike(
            damageType: EveEchoesAttribute.kineticDamage);
        expect(value, closeTo(7081.26, 0.1),
            reason: 'Kinetic Alpha Strike: Expected 7081.26, got $value');
      });

      test('Flight Velocity', () async {
        var value = await fitting.getCalculatedValueForItem(
            attribute: EveEchoesAttribute.flightVelocity, item: fitting.ship);
        expect(value, closeTo(123.76, 0.01),
            reason: "Incorrect flight velocity for the ship");
      });
    });
  });
}
