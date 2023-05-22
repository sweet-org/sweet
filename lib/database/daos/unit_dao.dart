

import '../database.dart';
import 'base_dao.dart';
import 'base_dao_mixin.dart';

import '../type_converters/type_converters.dart';

import '../entities/unit.dart';

class UnitDao extends BaseDao<Unit> with BaseDaoMixin {
  UnitDao(EveEchoesDatabase db) : super(db);

  @override
  String get tableName => 'unit';

  @override
  Map<String, TypeConverter> converters = {};

  @override
  Map<String, dynamic> mapItemToRow(Unit item) => item.toJson();

  @override
  Unit mapRowToItem(Map<String, dynamic> row) => Unit.fromJson(row);

  @override
  Map<String, String> get columnDefinitions => {
        'id': 'INTEGER PRIMARY KEY',
        'description': 'TEXT',
        'displayName': 'TEXT',
        'unitName': 'TEXT',
      };
}
