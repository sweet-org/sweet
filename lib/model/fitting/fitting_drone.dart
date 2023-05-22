import 'package:sweet/database/entities/entities.dart';
import 'package:sweet/model/ship/module_state.dart';
import 'package:sweet/service/fitting_simulator.dart';
import 'package:sweet/model/ship/slot_type.dart';

import 'fitting_module.dart';

class FittingDrone extends FittingModule {
  final FittingSimulator fitting;

  FittingDrone({
    required Item item,
    required List<Attribute> baseAttributes,
    required List<ItemModifier> modifiers,
    SlotType slot = SlotType.high,
    int index = 0,
    ModuleState state = ModuleState.active,
    required this.fitting,
  }) : super(
          item: item,
          baseAttributes: baseAttributes,
          modifiers: modifiers,
          slot: slot,
          index: index,
          state: state,
        );

  @override
  FittingDrone copyWith({
    SlotType? slot,
    int? index,
    ModuleState? state,
  }) {
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
