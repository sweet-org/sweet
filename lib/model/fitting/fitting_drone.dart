import 'package:sweet/model/ship/module_state.dart';
import 'package:sweet/service/fitting_simulator.dart';
import 'package:sweet/model/ship/slot_type.dart';

import 'fitting_module.dart';

class FittingDrone extends FittingModule {
  final FittingSimulator fitting;

  FittingDrone({
    required super.item,
    required super.baseAttributes,
    required super.modifiers,
    super.slot,
    super.index,
    super.state = ModuleState.active,
    required this.fitting,
  });

  @override
  FittingDrone copyWith({
    SlotType? slot,
    int? index,
    ModuleState? state,
    bool? isDroneModule = false,
  }) {
    if (isDroneModule != null && isDroneModule) {
      throw UnimplementedError(
        'Drone modules are not supported yet for drones',
      );
    }
    return FittingDrone(
      item: item,
      slot: slot ?? this.slot,
      index: index ?? this.index,
      state: state ?? this.state,
      baseAttributes: baseAttributes,
      modifiers: modifiers,
      fitting: fitting,
    );
  }
}
