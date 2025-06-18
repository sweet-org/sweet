

import 'base_dao.dart';
import 'base_dao_mixin.dart';

import '../type_converters/type_converters.dart';

import '../entities/ship_default_mode.dart';

class ShipModesDao extends BaseDao<ShipDefaultMode> with BaseDaoMixin {
  ShipModesDao(super.db);

  @override
  String get tableName => 'ship_modes';

  @override
  Map<String, TypeConverter> converters = {};

  @override
  Map<String, dynamic> mapItemToRow(ShipDefaultMode item) => item.toJson();

  @override
  ShipDefaultMode mapRowToItem(Map<String, dynamic> row) =>
      ShipDefaultMode.fromJson(row);

  @override
  String get tableConstraint => 'PRIMARY KEY(shipId, modeId)';

  @override
  Map<String, String> get columnDefinitions => {
        'shipId': 'INTEGER NOT NULL',
        'modeId': 'INTEGER NOT NULL',
      };
}
