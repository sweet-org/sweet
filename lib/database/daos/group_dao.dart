import '../../database/entities/category.dart';

import 'base_dao.dart';
import 'base_dao_mixin.dart';

import '../type_converters/type_converters.dart';

import '../../database/entities/group.dart';

class GroupDao extends BaseDao<Group> with BaseDaoMixin {
  GroupDao(super.db);

  @override
  String get tableName => 'groups';

  @override
  Map<String, TypeConverter> converters = {
    // 'anchorable': BoolTypeConverter(),
    // 'anchored': BoolTypeConverter(),
    // 'fittableNonSingleton': BoolTypeConverter(),
    // 'useBasePrice': BoolTypeConverter(),
    'itemIds': IntListTypeConverter(),
  };

  @override
  List<String> get ignoreKeys => [
        'itemsCount',
      ];

  @override
  Map<String, dynamic> mapItemToRow(Group item) => item.toJson();

  @override
  Group mapRowToItem(Map<String, dynamic> row) => Group.fromJson(row);

  @override
  Map<String, String> get columnDefinitions => {
        'id': 'INTEGER PRIMARY KEY',
        // 'anchorable': 'INTEGER NOT NULL',
        // 'anchored': 'INTEGER NOT NULL',
        // 'fittableNonSingleton': 'INTEGER NOT NULL',
        // 'iconPath': 'TEXT',
        // 'useBasePrice': 'INTEGER NOT NULL',
        'localisedNameIndex': 'INTEGER NOT NULL',
        'sourceName': 'TEXT',
        'itemIds': 'TEXT'
      };

  Future<Iterable<Group>> selectWithCategory(
          {required int categoryId, bool includeEmpty = false}) async =>
      await select_raw(query: '''
    SELECT $tableName.*, itemGroups.itemCount
    FROM $tableName
    LEFT JOIN (
      SELECT DISTINCT(${db.itemDao.tableName}.id / ${Group.itemToGroupIdDivisor}) AS groupId, COUNT(${db.itemDao.tableName}.id/${Group.itemToGroupIdDivisor}) AS itemCount
      FROM ${db.itemDao.tableName}
      GROUP BY groupId
    ) itemGroups ON itemGroups.groupId = $tableName.id
    WHERE $tableName.id/${Category.groupToCategoryIdDivisor} = $categoryId AND itemGroups.itemCount > 0
  ''');
}
