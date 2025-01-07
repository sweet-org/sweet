import 'package:equatable/equatable.dart';
import 'package:sweet/database/database_exports.dart';
import 'package:sweet/extensions/item_ui_extension.dart';
import 'package:sweet/model/ship/eve_echoes_attribute.dart';

import 'fitting_item.dart';
import '../ship/module_state.dart';
import '../ship/slot_type.dart';

class FittingModule extends FittingItem with EquatableMixin {
  final SlotType slot;
  final int index;
  final ModuleState state;
  final bool isDroneModule;

  Map<String, dynamic> get metadata => {};

  int get groupKey => itemId;

  bool get isValid => this != FittingModule.empty;
  bool get canActivate =>
      slot != SlotType.combatRig &&
      slot != SlotType.engineeringRig &&
      slot != SlotType.nanocore && slot != SlotType.implantSlots;

  bool inSameSlot(FittingModule other) =>
      other.slot == slot && other.index == index;

  List<EveEchoesAttribute> get uiAttributes => item.uiAttributes;

  static FittingModule empty = FittingModule(
    item: Item.invalid,
    baseAttributes: [],
    modifiers: [],
  );

  FittingModule({
    required Item item,
    this.slot = SlotType.high,
    this.index = 0,
    required List<Attribute> baseAttributes,
    required List<ItemModifier> modifiers,
    this.state = ModuleState.inactive,
    this.isDroneModule = false,
  }) : super(
          item: item,
          baseAttributes: baseAttributes,
          modifiers: modifiers,
        );

  FittingModule copyWith({
    SlotType? slot,
    int? index,
    ModuleState? state,
    bool? isDroneModule,
  }) {
    return FittingModule(
      item: item,
      slot: slot ?? this.slot,
      index: index ?? this.index,
      state: state ?? this.state,
      baseAttributes: baseAttributes,
      modifiers: modifiers,
      isDroneModule: isDroneModule ?? this.isDroneModule,
    );
  }

  @override
  List<Object> get props => [
        itemId,
        state,
      ];
}
