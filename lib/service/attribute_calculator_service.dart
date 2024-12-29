import 'dart:math';

import 'package:collection/collection.dart';
import 'package:expressions/expressions.dart';
import 'package:sprintf/sprintf.dart';

import 'package:sweet/database/entities/attribute.dart';
import 'package:sweet/database/entities/item_modifier.dart';
import 'package:sweet/model/fitting/fitting_implant.dart';
import 'package:sweet/model/fitting/fitting_item.dart';
import 'package:sweet/model/modifier_change_type.dart';
import 'package:sweet/model/nihilus_space_modifier.dart';

import 'package:sweet/model/ship/dogma_operators.dart';
import 'package:sweet/model/ship/eve_echoes_attribute.dart';
import 'package:sweet/model/fitting/fitting_skill.dart';
import 'package:sweet/model/fitting/fitting_ship.dart';
import 'package:sweet/model/fitting/fitting_module.dart';
import 'package:sweet/model/ship/modifier.dart';
import 'package:sweet/model/ship/module_state.dart';

import 'package:sweet/repository/item_repository.dart';
import 'package:sweet/util/constants.dart';

class AttributeCalculatorService {
  final ItemRepository itemRepository;

  // TASK: Separate to different groupings
  // So we can remove when removing items/pilots etc
  final Map<String, List<Modifier>> _modifiers = {};
  final Set<int> _modifierIds = <int>{};

  Map<int, Attribute> _attributeDefinitions = {};

  List<FittingSkill> _skills = [];
  FittingShip _ship = FittingShip.empty;
  Iterable<FittingModule> _allFittedModules = [];
  List<NihilusSpaceModifier> _nSpaceModifiers = [];
  final List<ItemModifier> _implantShieldArmorModifiers = [];
  List<ItemModifier> get implantShieldArmorModifiers =>
      _implantShieldArmorModifiers;

  bool logCalculations = false;
  bool logModifiers = false;

  AttributeCalculatorService({required this.itemRepository});

  ///
  /// Updating Attributes
  ///

  Future<void> setup({
    List<FittingSkill> skills = const [],
    required FittingShip ship,
    Iterable<FittingModule> allFittedModules = const [],
  }) async {
    _skills = skills;
    _ship = ship;
    _allFittedModules = allFittedModules;
    _log(message: 'Setting Up');

    return _updateModifiers();
  }

  Future<void> updateItems({
    required Iterable<FittingModule> allFittedModules,
  }) async {
    _allFittedModules = allFittedModules;
    _log(message: 'Updating Items');

    return _updateModifiers();
  }

  Future<void> updateNihilusModifiers({
    required Iterable<NihilusSpaceModifier> modifiers,
  }) async {
    _nSpaceModifiers = modifiers.toList();

    return _updateModifiers();
  }

  Future<void> updateImplantLevels({required int totalLevels}) async {
    _implantShieldArmorModifiers.clear();
    for (var implantMod in itemRepository.implantShieldArmorMods) {
      if (isLevelFunction(implantMod.attributeId)) {
        implantMod = implantMod.copyWith(
                attributeValue: getValueForLevelFunction(
                    implantMod.attributeId, totalLevels));
      }
      _implantShieldArmorModifiers.add(implantMod);
    }
    return _updateModifiers();
  }

  double getValueForLevelFunction(int attributeId, int lvl) {
    final expr = itemRepository.levelAttributeMap[attributeId]!;
    var context = {"lv": lvl.toDouble()};
    final evaluator = const ExpressionEvaluator();
    return evaluator.eval(expr, context).toDouble();
  }

  bool isLevelFunction(int attributeId) {
    return itemRepository.levelAttributeMap.containsKey(attributeId);
  }

  Future<void> _updateModifiers() async {
    // for each item - including ship
    // extract out any modifiers that are not 'self'
    // and store in Map<String, List<Modifier>> keyed on cal code path
    _modifiers.clear();
    _modifierIds.clear();

    _logModifier(message: 'Updating Modifiers');

    // Process skills
    for (var skill in _skills) {
      skill.selfModifiers.clear();
      final String modifierId =
          sprintf(skill.mainCalCode.first, [skill.skillLevel]);
      skill.modifiers.where((modifier) => modifier.code == modifierId).forEach(
          (modifier) =>
              processModifier(itemModifier: modifier, sourceItem: skill));
    }

    // Process ship bonus skills
    _ship.selfModifiers.clear();
    for (var i = 0; i < _ship.shipBonusCodeList.length; i++) {
      final modifierId = _ship.shipBonusCodeList[i];
      final skillId = _ship.shipBonusSkillList[i];
      final multiplier = _skills
              .firstWhereOrNull(
                (e) => e.itemId == skillId,
              )
              ?.skillLevel ??
          (skillId == 0 ? 1 : 0);

      _ship.modifiers.where((modifier) => modifier.code == modifierId).forEach(
            (modifier) => processModifier(
              itemModifier: modifier,
              multiplier: multiplier,
              sourceItem: _ship,
            ),
          );
    }

    var activeMods =
        _allFittedModules.where((module) => module.isValid).toList();

    if (_ship.shipMode != null &&
        _ship.shipMode!.state != ModuleState.inactive) {
      activeMods.add(_ship.shipMode!);
    }

    for (var moduleSlot in activeMods) {
      moduleSlot.selfModifiers.clear();
      final modifiers = [...moduleSlot.mainCalCode];
      final activeModifiers = moduleSlot.activeCalCode;

      if (moduleSlot.state != ModuleState.inactive ||
          moduleSlot is ImplantFitting) {
        // Implants handle their state on their own
        for (final activeModifier in activeModifiers) {
          if (!moduleSlot.mainCalCode.contains(activeModifier)) {
            modifiers.add(activeModifier);
          }
        }
      }

      final mods = moduleSlot.modifiers
          .where((modifier) => modifiers.contains(modifier.code));

      _logModifier(
        message:
            '${mods.length} modifiers for ${moduleSlot.itemId} in ${moduleSlot.slot}-${moduleSlot.index}',
      );

      for (var modifier in mods) {
        processModifier(
          itemModifier: modifier,
          sourceItem: moduleSlot,
        );
      }
    }

    for (var nSpaceMod in _nSpaceModifiers) {
      processModifier(
        itemModifier: nSpaceMod,
        sourceItem: FittingItem.empty,
      );
    }

    for (var implantMod in _implantShieldArmorModifiers) {
      processModifier(
        itemModifier: implantMod,
        sourceItem: FittingItem.empty,
      );
    }

    // Cache all modifier attribute definitions as well
    final ids = [
      ...kFittingAttributes.map((e) => e.attributeId),
      ..._modifierIds,
    ];
    _attributeDefinitions = {
      for (var mod in await itemRepository.attributesWithIds(
        ids: ids,
      ))
        mod.id: mod
    };

    // Add any missing attributes up the chains
    // This is noticeable with certain bonuses (see: 3029/3030)
    final missing = _attributeDefinitions.values
        .map((a) => a.toAttrId)
        .expand((e) => e)
        .whereNot(_attributeDefinitions.containsKey)
        .toList();
    final m = {
      for (var mod in await itemRepository.attributesWithIds(
        ids: missing,
      ))
        mod.id: mod
    };

    _attributeDefinitions.addAll(m);
  }

  void processModifier({
    required ItemModifier itemModifier,
    required FittingItem sourceItem,
    int multiplier = 1,
  }) {
    _logModifier(
      message:
          'Processing Modifier ${itemModifier.code} on item ${sourceItem.itemId} for attribute ${itemModifier.attributeId}',
      divider: true,
    );

    var changeType = itemModifier.changeType;
    var changeRange = itemModifier.changeRange;
    var attributeId = itemModifier.attributeId;
    var attributeValue = itemModifier.attributeValue;

    // NOTE: TARGET_MODULE was removed here as this broke how Command Modules
    // would apply their bonuses. This might be a bug in the future? More testing
    // is required!
    // 2021-11-17: Updated to apply if the isFleetOnly attribute is there
    var canApplyTargetModule = sourceItem.baseAttributes
        .where(
          (e) => e.id == EveEchoesAttribute.isFleetOnly.attributeId,
        )
        .isNotEmpty;
    if ((changeType == ModifierChangeType.TARGET_MODULE &&
            !canApplyTargetModule) ||
        changeType == ModifierChangeType.TARGET ||
        changeType == ModifierChangeType.STRUCTURE) {
      _log(message: 'Skipping...');
      return;
    }

    var modifier = Modifier(
      modifierValue: attributeValue * multiplier,
      attributeId: attributeId,
      changeScope: changeType,
      changeRange: changeRange,
      item: sourceItem,
    );

    if (modifier.changeScope == ModifierChangeType.SELF) {
      sourceItem.selfModifiers.add(modifier);
      _logModifier(message: 'Added as self modifier');
    } else {
      changeRange.split('|').forEach(
        (range) {
          if (_modifiers.containsKey(range) == false) {
            _modifiers[range] = <Modifier>[];
          }
          _modifiers[range]!.add(modifier);
          _logModifier(message: 'Added as $range modifier');
        },
      );
    }
    _modifierIds.add(attributeId);
  }

  double getValueForItem({
    required EveEchoesAttribute attribute,
    required FittingItem item,
    bool isDrone = false,
  }) {
    return attribute.attributeId > 0
        ? _getValueForItemWithAttributeId(
            attributeId: attribute.attributeId,
            item: item,
            isDrone: isDrone,
            depth: 0,
          )
        : calculateValueForAttribute(attribute: attribute, item: item);
  }

  double getValueForItemWithAttributeId({
    required int attributeId,
    required FittingItem item,
    bool isDrone = false,
  }) =>
      _getValueForItemWithAttributeId(
        attributeId: attributeId,
        item: item,
        isDrone: isDrone,
        depth: 0,
      );

  int _logDepth = 0;

  double _getValueForItemWithAttributeId({
    required int attributeId,
    required FittingItem item,
    required int depth,
    bool isDrone = false,
    double? baseValue,
  }) {
    _logDepth = depth;
    _log(
      message:
          'Getting value for $attributeId on item ${item.itemId} with baseValue $baseValue, isDrone: $isDrone',
      divider: true,
    );
    if (attributeId == 0) {
      return 0.0;
    }

    final itemAttribute = item.baseAttributes
            .firstWhereOrNull((attr) => attr.id == attributeId) ??
        _attributeDefinitions[attributeId];

    if (itemAttribute == null) {
      _log(message: 'No item attribute');
      return baseValue ?? 0.0;
    }

    final filteredModifiers = _modifiers.entries
        .where(
          (entry) => item.mainCalCode.any(
            (e) => e.contains(RegExp(entry.key)),
          ),
        )
        .map((e) => e.value)
        .expand((e) => e)
        .where(
      (modifier) {
        final isDroneModifier =
            modifier.changeScope == ModifierChangeType.DRONE ||
                modifier.changeScope == ModifierChangeType.DRONEMODULE;
        // Testing for Salvage modifiers, as these are annoying
        // (They both have the same Change Range Path)
        if (item.groupId == 11131 || item.groupId == 11117) {
          return (item.groupId == 11131 && isDroneModifier) ||
              (item.groupId == 11117 && !isDroneModifier);
        }

        /* ToDo: This might should be isDrone == isDroneModifier, but it was
            just a return true before and did not cause any problems for normal
            items. So a check for drones might be sufficient.
        */
        final onlyDroneModule = modifier.changeScope == ModifierChangeType.DRONEMODULE;
        final onlyDrone = modifier.changeScope == ModifierChangeType.DRONE;
        return isDrone == (onlyDrone || onlyDroneModule) || (!isDrone && !onlyDrone);
      },
    );

    final modifiers = [
      ...item.selfModifiers,
      ...filteredModifiers,
    ];

    var value = baseValue ?? itemAttribute.baseValue;
    _log(message: 'Base value for $attributeId is $value');
    if (item is ImplantFitting && isLevelFunction(itemAttribute.id)) {
      value = getValueForLevelFunction(itemAttribute.id, item.trainedLevel);
    }

    // NOTE: Scripts seem to run through a map of
    // [ Operation ] [ Attr ID] [ Attr List]
    var modifiersByOperation = <DogmaOperators, Map<int, List<Modifier>>>{};

    modifiers.where((modifier) {
      var attrDefinition = _attributeDefinitions[modifier.attributeId];
      return attrDefinition?.toAttrId.contains(itemAttribute.id) ?? false;
    }).forEach((modifier) {
      var attrDefinition = _attributeDefinitions[modifier.attributeId]!;
      var op = DogmaOperators.values[attrDefinition.attributeOperator.first];

      if (!modifiersByOperation.containsKey(op)) {
        modifiersByOperation[op] = {};
      }

      if (!modifiersByOperation[op]!.containsKey(modifier.attributeId)) {
        modifiersByOperation[op]![modifier.attributeId] = [];
      }

      modifiersByOperation[op]![modifier.attributeId]!.add(modifier);
    });
    // }

    // Now we need to apply them all
    var modifiersToApply = modifiersByOperation.entries.toList();
    if (logModifiers) {
      var modNames = "";
      for (var mod in modifiers) {
        modNames +=
            "<${mod.changeRange}, ${mod.changeScope.name}, ${mod.item.itemId}, ${mod.attributeId}>, ";
      }
      _log(message: 'Found ${modifiers.length} modifiers: $modNames');
    }
    _log(message: 'Found ${modifiersToApply.length} modifiers to apply');
    modifiersToApply.sort((a, b) {
      var aIdx = DogmaOperators.values.indexOf(a.key);
      var bIdx = DogmaOperators.values.indexOf(b.key);
      return aIdx < bIdx ? -1 : 1;
    });

    for (var opKvp in modifiersToApply) {
      final op = opKvp.key;
      final opModValue = _applyOperation(
        modsByAttrId: opKvp.value,
        op: op,
        itemAttribute: itemAttribute,
        isDrone: isDrone,
      );

      if (opModValue != null) {
        _log(message: 'Performing $op on $value with $opModValue ($attributeId for ${item.itemId})');
        value = op.performOperation(
          ret: value,
          value: opModValue,
        );
      }
    }
    _log(message: 'Value after modifiers is $value');

    // if Damage attribute, we want to check for Damage Modifiers too
    // Need to check self for any (which there should be)
    if (kDamageAttributes.map((e) => e.attributeId).contains(attributeId)) {
      _log(message: 'Getting Damage Multiplier');
      var damageMod = getValueForItem(
        attribute: EveEchoesAttribute.damageMultiplier,
        item: item,
        isDrone: isDrone,
      );

      value *= damageMod;
      _log(message: 'Damage Multiplier is $damageMod');
    }

    _log(message: 'Final Value for $attributeId is $value');
    _logDepth = max(0, _logDepth - 1);
    _log(divider: true);
    return value;
  }

  double? _applyOperation({
    required Map<int, List<Modifier>> modsByAttrId,
    required DogmaOperators op,
    required Attribute itemAttribute,
    bool isDrone = false,
  }) {
    double? opModValue;
    _log(
        message:
            'Applying ${modsByAttrId.length} mods with $op to ${itemAttribute.id}');

    for (var modKvp in modsByAttrId.entries) {
      _log(message: 'Applying ${modKvp.value.length} modifiers for ${modKvp.key}');
      var attrDefinition = _attributeDefinitions[modKvp.key]!;
      var modifierList = modKvp.value.map((e) {
        // Calculate with Self modifiers applied
        final val = _getValueForItemWithAttributeId(
          attributeId: e.attributeId,
          item: e.item,
          depth: ++_logDepth,
          baseValue: e.modifierValue,
          isDrone: isDrone,
        );

        return Modifier(
          modifierValue: val,
          attributeId: e.attributeId,
          changeRange: e.changeRange,
          changeScope: e.changeScope,
          item: e.item,
        );
      }).toList();

      if (!attrDefinition.stackable) {
        _log(message: 'Sorting non-stackable modifiers');
        modifierList.sort(
            (a, b) => a.modifierValue.abs() > b.modifierValue.abs() ? -1 : 1);

        if (!attrDefinition.highIsGood) {
          modifierList = modifierList.reversed.toList();
        }
      }

      double? modValue;
      modifierList.forEachIndexed((index, modifier) {
        var modifierValue = modifier.modifierValue;

        if (!attrDefinition.stackable) {
          // Ignore all values past the max nurf
          if (index >= kMaxNurfSequenceLength) return;
          assert(index < kNurfDenominators.length);
          _log(
              message:
                  'Applying stacking penalty of ${kNurfDenominators[index]}');
          modifierValue *= kNurfDenominators[index];
        }

        if (modValue == null) {
          modValue = modifierValue;
          _log(message: 'Setting modValue to $modifierValue for attrId ${modKvp.key}');
        } else {
          _log(
              message:
                  'Performing $op aggregation on $modValue with $modifierValue from <${modifier.item.itemId}, ${modifier.changeScope.name}, ${modifier.changeRange}>');
          modValue = op.performAggregation(
            highIsGood: attrDefinition.highIsGood,
            a: modValue!,
            b: modifierValue,
          );
        }
      }); // End Apply Modifier

      if (opModValue == null) {
        opModValue = modValue;
        _log(message: 'Setting opModValue to $modValue');
      } else {
        _log(
            message:
                'Performing final $op aggregation on $opModValue with $modValue');
        opModValue = op.performAggregation(
          highIsGood: itemAttribute.highIsGood,
          a: opModValue,
          b: modValue ?? 0,
        );
      }
    }

    return opModValue;
  }

  double calculateValueForAttribute({
    required EveEchoesAttribute attribute,
    required FittingItem item,
  }) {
    switch (attribute) {
      case EveEchoesAttribute.missileRange:
        return getValueForItem(
              attribute: EveEchoesAttribute.flightTime,
              item: item,
            ) *
            getValueForItem(
              attribute: EveEchoesAttribute.flightVelocity,
              item: item,
            );

      default:
        return 0;
    }
  }

  void _logModifier({String message = '', bool divider = false}) {
    if (logModifiers) {
      _log(message: message, divider: divider);
    }
  }

  void _log({String message = '', bool divider = false}) {
    if (logCalculations) {
      if (divider) {
        print('------------------');
      }

      final prefix = '   ' * _logDepth;
      print('$prefix$message');
    }
  }
}
