import 'base_dao.dart';
import 'base_dao_mixin.dart';

import '../type_converters/type_converters.dart';

import '../entities/level_attribute.dart';

class LevelAttributeDao extends BaseDao<LevelAttribute> with BaseDaoMixin {
  LevelAttributeDao(super.db);

  @override
  String get tableName => 'level_attribute';

  @override
  Map<String, TypeConverter> converters = {};

  @override
  Map<String, dynamic> mapItemToRow(LevelAttribute item) => item.toJson();

  @override
  LevelAttribute mapRowToItem(Map<String, dynamic> row) => LevelAttribute.fromJson(row);

  @override
  Map<String, String> get columnDefinitions => {
        'attrId': 'INTEGER PRIMARY KEY',
        'formula': 'TEXT NOT NULL',
      };
}
