import 'package:sweet/model/ship/ship_fitting_loadout.dart';
import 'package:sweet/model/ship/ship_loadout_definition.dart';
import 'package:sweet/model/ship/slot_type.dart';

import 'fitting_module.dart';

class Fitting {
  final _fittingData = <SlotType, List<FittingModule>>{};

  final String id;

  String name;

  Fitting({
    required this.id,
    required this.name,
  });

  Iterable<FittingModule> get allFittedModules =>
      _fittingData.values.expand((e) => e).where((e) => e.isValid);

  Iterable<FittingModule> fittedModulesForSlot(SlotType slot) =>
      _fittingData[slot]!.where((e) => e.isValid);

  List<FittingModule>? operator [](SlotType i) => _fittingData[i];
  operator []=(SlotType i, List<FittingModule> value) =>
      _fittingData[i] = value;

  void setLoadoutFromDefinition(ShipLoadoutDefinition definition) {
    _fittingData.clear();

    _fittingData[SlotType.high] =
        List.filled(definition.numHighSlots, FittingModule.empty);
    _fittingData[SlotType.mid] =
        List.filled(definition.numMidSlots, FittingModule.empty);
    _fittingData[SlotType.low] =
        List.filled(definition.numLowSlots, FittingModule.empty);
    _fittingData[SlotType.combatRig] =
        List.filled(definition.numCombatRigSlots, FittingModule.empty);
    _fittingData[SlotType.engineeringRig] =
        List.filled(definition.numEngineeringRigSlots, FittingModule.empty);
    _fittingData[SlotType.drone] =
        List.filled(definition.numDroneSlots, FittingModule.empty);
    _fittingData[SlotType.nanocore] =
        List.filled(definition.numNanocoreSlots, FittingModule.empty);
    _fittingData[SlotType.hangarRigSlots] =
        List.filled(definition.numHangarRigSlots, FittingModule.empty);
    _fittingData[SlotType.lightFFSlot] =
        List.filled(definition.numLightFrigatesSlots, FittingModule.empty);
    _fittingData[SlotType.lightDDSlot] =
        List.filled(definition.numLightDestroyersSlots, FittingModule.empty);
  }

  void setFromLoadout(ShipFittingLoadout loadout) {
    _fittingData.clear();

    _fittingData[SlotType.high] =
        List.filled(loadout.highSlots.maxSlots, FittingModule.empty);
    _fittingData[SlotType.mid] =
        List.filled(loadout.midSlots.maxSlots, FittingModule.empty);
    _fittingData[SlotType.low] =
        List.filled(loadout.lowSlots.maxSlots, FittingModule.empty);
    _fittingData[SlotType.combatRig] =
        List.filled(loadout.combatRigSlots.maxSlots, FittingModule.empty);
    _fittingData[SlotType.engineeringRig] =
        List.filled(loadout.engineeringRigSlots.maxSlots, FittingModule.empty);
    _fittingData[SlotType.drone] =
        List.filled(loadout.droneBay.maxSlots, FittingModule.empty);
    _fittingData[SlotType.nanocore] =
        List.filled(loadout.nanocoreSlots.maxSlots, FittingModule.empty);

    _fittingData[SlotType.hangarRigSlots] =
        List.filled(loadout.hangarRigSlots.maxSlots, FittingModule.empty);
    _fittingData[SlotType.lightFFSlot] =
        List.filled(loadout.lightFrigatesSlots.maxSlots, FittingModule.empty);
    _fittingData[SlotType.lightDDSlot] =
        List.filled(loadout.lightDestroyersSlots.maxSlots, FittingModule.empty);
  }

  void updateLoadout(ShipLoadoutDefinition updatedLoadout) {
    final mapped = {
      SlotType.high: updatedLoadout.numHighSlots,
      SlotType.mid: updatedLoadout.numMidSlots,
      SlotType.low: updatedLoadout.numLowSlots,
      SlotType.drone: updatedLoadout.numDroneSlots,
      SlotType.combatRig: updatedLoadout.numCombatRigSlots,
      SlotType.engineeringRig: updatedLoadout.numEngineeringRigSlots,
      SlotType.nanocore: updatedLoadout.numNanocoreSlots,
      SlotType.lightFFSlot: updatedLoadout.numLightFrigatesSlots,
      SlotType.lightDDSlot: updatedLoadout.numLightDestroyersSlots,
      SlotType.hangarRigSlots: updatedLoadout.numHangarRigSlots,
    };

    mapped.forEach((key, value) {
      _fittingData[key] = _updateSlotModules(
        slot: key,
        newCount: value,
        currentList: _fittingData[key] ?? [],
      );
    });
  }

  List<FittingModule> _updateSlotModules(
      {required SlotType slot,
      required int newCount,
      required List<FittingModule> currentList}) {
    if (currentList.length != newCount) {
      final currentLength = currentList.length;

      if (currentLength > newCount) {
        return currentList.sublist(0, newCount);
      } else {
        return [
          currentList,
          List.filled(newCount - currentLength, FittingModule.empty),
        ].expand((e) => e).toList();
      }
    }
    return currentList;
  }
}
