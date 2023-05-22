
import '../database.dart';
import 'base_dao.dart';
import 'base_dao_mixin.dart';

import '../type_converters/type_converters.dart';

import '../entities/category.dart';

class CategoryDao extends BaseDao<Category> with BaseDaoMixin {
  CategoryDao(EveEchoesDatabase db) : super(db);

  @override
  String get tableName => 'categories';

  @override
  Map<String, TypeConverter> converters = {'groupIds': IntListTypeConverter()};

  @override
  List<String> get ignoreKeys => [
        'itemsCount',
      ];

  @override
  Map<String, dynamic> mapItemToRow(Category item) => item.toJson();

  @override
  Category mapRowToItem(Map<String, dynamic> row) => Category.fromJson(row);

  @override
  Map<String, String> get columnDefinitions => {
        'id': 'INTEGER PRIMARY KEY',
        'groupIds': 'TEXT',
        'localisedNameIndex': 'INTEGER NOT NULL DEFAULT 0',
        'sourceName': 'TEXT'
      };

  Future<Iterable<Category>> selectAllNonEmpty() async =>
      await select_raw(query: '''
  SELECT COUNT(${db.itemDao.tableName}.id / ${Category.itemToCategoryIdDivisor}) AS itemsCount, $tableName.*
  FROM $tableName
  LEFT JOIN ${db.itemDao.tableName} ON (${db.itemDao.tableName}.id / 1000000000) = $tableName.id
  GROUP BY $tableName.id
  HAVING itemsCount > 0
''');
}
