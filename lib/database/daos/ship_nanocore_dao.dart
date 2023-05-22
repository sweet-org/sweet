import '../database.dart';
import 'base_dao.dart';
import 'base_dao_mixin.dart';

import '../type_converters/type_converters.dart';

class ShipNanocore {
  final int shipId;
  final int nanocoreId;

  ShipNanocore({
    required this.shipId,
    required this.nanocoreId,
  });

  factory ShipNanocore.fromJson(Map<String, dynamic> json) => ShipNanocore(
        shipId: json['shipId'],
        nanocoreId: json['nanocoreId'],
      );

  Map<String, dynamic> toJson() => {
        'shipId': shipId,
        'nanocoreId': nanocoreId,
      };
}

class ShipNanocoreDao extends BaseDao<ShipNanocore> with BaseDaoMixin {
  ShipNanocoreDao(EveEchoesDatabase db) : super(db);

  @override
  String get tableName => 'ship_nanocore';

  @override
  Map<String, TypeConverter> converters = {};

  @override
  Map<String, dynamic> mapItemToRow(ShipNanocore item) => item.toJson();

  @override
  ShipNanocore mapRowToItem(Map<String, dynamic> row) =>
      ShipNanocore.fromJson(row);

  @override
  String get tableConstraint => 'PRIMARY KEY(shipId, nanocoreId)';

  @override
  Map<String, String> get columnDefinitions => {
        'shipId': 'INTEGER NOT NULL',
        'nanocoreId': 'INTEGER NOT NULL',
      };
}
