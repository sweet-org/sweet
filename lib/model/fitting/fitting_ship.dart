import 'package:sweet/database/entities/entities.dart';
import 'package:sweet/model/ship/eve_echoes_attribute.dart';
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

  // I don't think there are any modifiers that change ship size
  int _shipSize = -1;

  int get shipSize => _shipSize;

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
    required super.item,
    FittingModule? shipMode,
    required super.baseAttributes,
    required super.modifiers,
  }) : _shipMode = shipMode {
    final sizeAttr = this
        .baseAttributes
        .where((attr) => attr.id == EveEchoesAttribute.shipSize.attributeId)
        .firstOrNull;
    if (sizeAttr != null) {
      _shipSize = sizeAttr.baseValue.toInt();
    }
  }
}
