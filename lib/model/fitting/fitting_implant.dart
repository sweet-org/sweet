import 'package:collection/collection.dart';
import 'package:sweet/model/fitting/fitting_implant_module.dart';
import 'package:sweet/model/implant/implant_fitting_loadout.dart';
import 'package:sweet/model/implant/implant_loadout_definition.dart';
import 'package:sweet/model/implant/slot_type.dart';
import 'package:sweet/model/ship/module_state.dart';
import 'package:sweet/model/ship/slot_type.dart';

import '../../database/entities/attribute.dart';
import '../../database/entities/item.dart';
import '../../database/entities/item_modifier.dart';

import 'fitting_module.dart';

class ImplantFitting extends FittingModule {
  final Map<int, FittingImplantModule> _implantSlots = {};
  int trainedLevel = 15;
  ModuleState primarySkillState = ModuleState.inactive;

  final String id;
  String name;
  final bool isPassive;

  Iterable<FittingImplantModule> get allModules => _implantSlots.values;

  ImplantFitting({
    required this.id,
    required this.name,
    required this.trainedLevel,
    required this.isPassive,
    required Item item,
    required List<Attribute> baseAttributes,
    required List<ItemModifier> modifiers,
  }) : super(
    item: item,
    baseAttributes: baseAttributes,
    modifiers: modifiers,
    slot: SlotType.implantSlots
  );

  FittingImplantModule? operator [](int i) => _implantSlots[i];
  operator []=(int i, FittingImplantModule value) =>
      _implantSlots[i] = value;

  int getSlotIdByIndex(int index) {
    return _implantSlots.keys.sorted((a, b) => a - b)[index];
  }

  FittingImplantModule? getModuleByIndex(int index) {
    return _implantSlots[getSlotIdByIndex(index)];
  }

  void setFromLoadoutDefiniton(ImplantLoadoutDefinition loadout) {
    _implantSlots.clear();

    loadout.slots.forEach((slotIndex, slot) {
      if (slot == ImplantSlotType.disabled) return;
      _implantSlots[slotIndex] = FittingImplantModule.getEmpty(slot);
    });
  }

  void setFromLoadout(ImplantFittingLoadout loadout) {
    _implantSlots.clear();
    trainedLevel = loadout.level;

    loadout.modules.forEach((slotIndex, module) {
      if (module.type == ImplantSlotType.disabled) return;
      _implantSlots[slotIndex] = FittingImplantModule.getEmpty(module.type);
    });
  }

  @override
  List<ItemModifier> get modifiers {
    final mods = [
      ...super.modifiers,
      ...allModules.map((e) => e.modifiers).expand((e) => e)
    ].whereNotNull().toList();

    return mods;
  }

  List<Attribute> get primarySkillAttributes => super.baseAttributes;

  @override
  List<Attribute> get baseAttributes => [
    ...super.baseAttributes,
    ...allModules.map((e) => e.baseAttributes).expand((element) => element),
  ].toList();

  @override
  List<String> get mainCalCode => [
    ...super.mainCalCode,
    ...allModules
        .map((e) => e.mainCalCode)
        .expand((e) => e),
  ].toList();

  @override
  List<String> get activeCalCode => [
    ...(primarySkillState == ModuleState.active ? super.activeCalCode : [""]),
    ...allModules
        .where((e) => e.state == ModuleState.active)
        .map((e) => e.activeCalCode)
        .expand((e) => e),
  ].where((e) => e != "").toList();

}