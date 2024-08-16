import 'package:collection/collection.dart';
import 'package:sweet/model/fitting/fitting_implant_module.dart';
import 'package:sweet/model/implant/implant_fitting_loadout.dart';
import 'package:sweet/model/implant/implant_loadout_definition.dart';

import 'fitting_item.dart';

class ImplantFitting {
  final Map<int, FittingImplantModule> _implantSlots = {};
  int trainedLevel = 1;

  final String id;
  String name;

  Iterable<FittingImplantModule> get allModules => _implantSlots.values;

  ImplantFitting({
    required this.id,
    required this.name,
  });

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
      _implantSlots[slotIndex] = FittingImplantModule.getEmpty(slot);
    });
  }

  void setFromLoadout(ImplantFittingLoadout loadout) {
    _implantSlots.clear();

    loadout.modules.forEach((slotIndex, module) {
      _implantSlots[slotIndex] = FittingImplantModule.getEmpty(module.type);
    });
  }
}