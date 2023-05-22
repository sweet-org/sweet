import 'package:sweet/database/entities/entities.dart';
import 'package:sweet/model/ship/module_state.dart';

import 'fitting_item.dart';
import 'fitting_module.dart';

class FittingShip extends FittingItem {
  static FittingShip get empty => FittingShip(
        item: Item.invalid,
        shipMode: FittingModule.empty,
        baseAttributes: [],
        modifiers: [],
      );
  // Can be null
  FittingModule? _shipMode;
  FittingModule? get shipMode => _shipMode;

  List<String> get shipBonusCodeList => item.shipBonusCodeList ?? [];
  List<int> get shipBonusSkillList => item.shipBonusSkillList ?? [];

  void setShipModeEnabled(bool enabled) {
    if (_shipMode != null) {
      _shipMode = _shipMode!.copyWith(
        state: enabled ? ModuleState.active : ModuleState.inactive,
      );
    }
  }

  FittingShip({
    required Item item,
    FittingModule? shipMode,
    required List<Attribute> baseAttributes,
    required List<ItemModifier> modifiers,
  })  : _shipMode = shipMode,
        super(
          item: item,
          baseAttributes: baseAttributes,
          modifiers: modifiers,
        );
}
