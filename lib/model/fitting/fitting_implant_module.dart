import 'package:equatable/equatable.dart';
import 'package:sweet/database/database_exports.dart';
import 'package:sweet/extensions/item_ui_extension.dart';
import 'package:sweet/model/ship/eve_echoes_attribute.dart';

import 'fitting_item.dart';
import '../ship/module_state.dart';
import '../implant/slot_type.dart';

class FittingImplantModule extends FittingItem with EquatableMixin {
  final ImplantSlotType slot;
  /// Level is -1 for invalid/placeholder items. For real items it is the slot
  /// level.
  final int level;
  final ModuleState state;

  Map<String, dynamic> get metadata => {};

  int get groupKey => itemId;

  bool get isValid => level != -1 && item.id != 0;

  bool inSameSlot(FittingImplantModule other) => other.level == level;

  List<EveEchoesAttribute> get uiAttributes => item.uiAttributes;

  static final FittingImplantModule _empty = FittingImplantModule(
    item: Item.invalid,
    slot: ImplantSlotType.common,
    level: -1,
    baseAttributes: [],
    modifiers: [],
  );

  static FittingImplantModule get emptyBranch => _empty.copyWith(
      slot: ImplantSlotType.branch, state: ModuleState.inactive, level: -1
  );
  static FittingImplantModule get emptyCommon => _empty.copyWith(
      slot: ImplantSlotType.common, state: ModuleState.inactive, level: -1
  );
  static FittingImplantModule get emptyUpgrade => _empty.copyWith(
      slot: ImplantSlotType.upgrade, state: ModuleState.inactive, level: -1
  );


  static getEmpty(ImplantSlotType type) {
    switch (type) {
      case ImplantSlotType.branch:
        return emptyBranch;
      case ImplantSlotType.common:
        return emptyCommon;
      case ImplantSlotType.upgrade:
        return emptyUpgrade;
    }
  }

  FittingImplantModule({
    required Item item,
    required this.slot,
    required this.level,
    required List<Attribute> baseAttributes,
    required List<ItemModifier> modifiers,
    this.state = ModuleState.inactive,
  }) : super(
    item: item,
    baseAttributes: baseAttributes,
    modifiers: modifiers,
  );

  FittingImplantModule copyWith({
    ImplantSlotType? slot,
    int? level,
    ModuleState? state,
  }) {
    return FittingImplantModule(
      item: item,
      slot: slot ?? this.slot,
      level: level ?? this.level,
      baseAttributes: baseAttributes,
      modifiers: modifiers,
    );
  }

  @override
  List<Object> get props => [
    itemId,
  ];
}
