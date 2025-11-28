import 'base_dao.dart';
import 'base_dao_mixin.dart';

import '../type_converters/type_converters.dart';

import '../entities/item.dart';
import '../entities/category.dart';

class ItemDao extends BaseDao<Item> with BaseDaoMixin {
  ItemDao(super.db);

  @override
  String get tableName => 'items';

  @override
  Map<String, TypeConverter> converters = {
    // 'canBeJettisoned': BoolTypeConverter(),
    'descSpecial': IntListTypeConverter(),
    // 'abilityList': IntListTypeConverter(),
    // 'normalDebris': IntListTypeConverter(),
    'shipBonusSkillList': IntListTypeConverter(),
    // 'lockSkin': StringListTypeConverter(),
    // 'npcCalCodes': StringListTypeConverter(),
    'preSkill': StringListTypeConverter(),
    'shipBonusCodeList': StringListTypeConverter(),
    // 'corpCamera': DoubleListTypeConverter(),
  };

  @override
  Map<String, dynamic> mapItemToRow(Item item) => item.toJson();

  @override
  Item mapRowToItem(Map<String, dynamic> row) => Item.fromJson(row);

  @override
  Map<String, String> get columnDefinitions => {
        'id': 'INTEGER PRIMARY KEY',
        // 'basePrice': 'INTEGER NOT NULL DEFAULT 0',
        // 'canBeJettisoned': 'INTEGER NOT NULL',
        // 'capacity': 'INTEGER',
        'descSpecial': 'TEXT NOT NULL',
        // 'factionId': 'INTEGER',
        // 'iconId': 'INTEGER NOT NULL DEFAULT 0',
        // 'isOmega': 'INTEGER NOT NULL DEFAULT 0',
        'mainCalCode': 'TEXT NOT NULL DEFAULT ""',
        'onlineCalCode': 'TEXT DEFAULT ""',
        'activeCalCode': 'TEXT DEFAULT ""',
        // 'mass': 'REAL',
        // 'prefabId': 'INTEGER',
        // 'radius': 'INTEGER NOT NULL DEFAULT 0',
        // 'soundId': 'INTEGER',
        // 'volume': 'REAL NOT NULL DEFAULT 0',
        'sourceDesc': 'TEXT NOT NULL',
        'sourceName': 'TEXT NOT NULL',
        'nameKey': 'INTEGER NOT NULL',
        'descKey': 'INTEGER NOT NULL',
        // 'dropRate': 'REAL NOT NULL DEFAULT 0',
        'marketGroupId': 'INTEGER',
        // 'graphicId': 'INTEGER',
        // 'raceId': 'INTEGER',
        // 'sofFactionName': 'TEXT',
        // 'lockSkin': 'TEXT',
        // 'npcCalCodes': 'TEXT',
        // 'lockWreck': 'INTEGER',
        'product': 'INTEGER',
        // 'skinId': 'INTEGER',
        // 'corporationId': 'INTEGER',
        // 'portraitPath': 'TEXT',
        // 'cloneLv': 'INTEGER',
        // 'effectGroup': 'TEXT',
        'exp': 'REAL NOT NULL DEFAULT 0',
        // 'initLv': 'INTEGER',
        'published': 'INTEGER NOT NULL DEFAULT 0',
        // 'techLv': 'INTEGER',
        'preSkill': 'TEXT',
        // 'corpCamera': 'TEXT NOT NULL',
        // 'wreckId': 'INTEGER',
        // 'museumCredit': 'INTEGER',
        // 'museumPosition1': 'INTEGER',
        // 'museumPosition2': 'INTEGER',
        // 'wikiId': 'TEXT',
        // 'bigIconPath': 'TEXT',
        // 'boxDropId': 'INTEGER',
        // 'funParam': 'TEXT',
        // 'isObtainable': 'INTEGER NOT NULL DEFAULT 0',
        // 'medalSourceText': 'INTEGER',
        // 'abilityList': 'TEXT NOT NULL',
        // 'baseDropRate': 'REAL NOT NULL DEFAULT 0',
        // 'normalDebris': 'TEXT NOT NULL',
        'shipBonusCodeList': 'TEXT NOT NULL',
        'shipBonusSkillList': 'TEXT NOT NULL',
        // 'isRookieInsurance': 'INTEGER NOT NULL DEFAULT 0',
      };

  Future<Iterable<Item>> selectWithCategory({required int categoryId}) async =>
      await select(whereClause: '''
        WHERE id >= ${categoryId * 1000000000} AND id < ${(categoryId + 1) * 1000000000}
      ''');

  Future<Iterable<Item>> selectWithGroup({required int groupId}) async =>
      await select(whereClause: 'WHERE id / 1000000 = $groupId');

  // This will work for now, but is messy
  // TODO: Look at a better option for these custom filters
  Future<Iterable<Item>> filterOnName(
      {required String filter, required String languageCode}) async {
    final idsContainingFilter = await db.localisedStringDao.select(
      whereClause:
          'WHERE LOWER($languageCode) LIKE LOWER("%$filter%") OR LOWER(source) LIKE LOWER("%$filter%")',
    );

    final ids = idsContainingFilter.map((s) => s.id);

    return await select_raw(query: '''
      SELECT $tableName.*
      FROM $tableName
      WHERE nameKey IN (${ids.join(',')})
      ''');
  }

  Future<Iterable<Item>> filterOnNameAndMarketGroups(
          {required String filter,
          required String languageCode,
          required List<int> topLvlMarketGroupIds}) async {
    final marketGroupIdsString = topLvlMarketGroupIds.map((m) => m.toString()).join(",");
    return await select_raw(query: '''
      SELECT $tableName.*, ${db.localisedStringDao.tableName}.$languageCode AS langString, ${db.localisedStringDao.tableName}.source AS sourceString
      FROM $tableName
      LEFT JOIN ${db.localisedStringDao.tableName} ON $tableName.nameKey = ${db.localisedStringDao.tableName}.id
      WHERE (LOWER(langString) LIKE LOWER("%$filter%") OR LOWER(sourceString) LIKE LOWER("%$filter%")) AND marketGroupId / 100000 in ($marketGroupIdsString)
      ''');
  }

  Future<Iterable<int>> filterIdsOnNameAndMarketGroups(
          {required String filter,
          required String languageCode,
          required List<int> marketGroupIds}) async {
    filter = filter.toLowerCase();
    const midMarketGroupIdDivisor = 100;
    const topMarketGroupIdDivisor = 100000;
    // Okay, so market groups are hierarchical.
    // The top level has range 0-9999
    // The mid level has range 1000000-9999999
    // The low level has range 100000000-999999999
    // We need to group the marketGroupIds by their level and query accordingly

    final topLevelIds = <int>[];
    final midLevelIds = <int>[];
    final lowLevelIds = <int>[];
    for (final id in marketGroupIds) {
      if (id < 0) {
        continue;
      } else if (id < 1000000) {
        topLevelIds.add(id);
      } else if (id < 100000000) {
        midLevelIds.add(id);
      } else {
        lowLevelIds.add(id);
      }
    }
    if (topLevelIds.isEmpty &&
        midLevelIds.isEmpty &&
        lowLevelIds.isEmpty) {
      return [];
    }
    final topLevelQuery = topLevelIds.isNotEmpty
        ? 'marketGroupId / $topMarketGroupIdDivisor IN (${topLevelIds.map((m) => m.toString()).join(",")})'
        : 'FALSE';
    final midLevelQuery = midLevelIds.isNotEmpty
        ? 'marketGroupId / $midMarketGroupIdDivisor IN (${midLevelIds.map((m) => m.toString()).join(",")})'
        : 'FALSE';
    final lowLevelQuery = lowLevelIds.isNotEmpty
        ? 'marketGroupId IN (${lowLevelIds.map((m) => m.toString()).join(",")})'
        : 'FALSE';
    return await db.db.rawQuery('''
      SELECT $tableName.id
      FROM $tableName
               LEFT JOIN ${db.localisedStringDao.tableName} ON $tableName.nameKey = ${db.localisedStringDao.tableName}.id
      WHERE (${db.localisedStringDao.tableName}.$languageCode LIKE '%$filter%' OR ${db.localisedStringDao.tableName}.source LIKE '%$filter%')
        AND ($topLevelQuery OR $midLevelQuery OR $lowLevelQuery)
      ''').then((values) => values.map((value) => value["id"] as int));
  }

  Future<Iterable<Item>> filterOnNameAndCategory({
    required String filter,
    required String languageCode,
    required int categoryId,
    bool allItems = false,
  }) async =>
      await select_raw(query: '''
      SELECT $tableName.*, ${db.localisedStringDao.tableName}.$languageCode AS langString, ${db.localisedStringDao.tableName}.source AS sourceString
      FROM $tableName
      LEFT JOIN ${db.localisedStringDao.tableName} ON $tableName.nameKey = ${db.localisedStringDao.tableName}.id
      WHERE (LOWER(langString) LIKE LOWER("%$filter%") OR LOWER(sourceString) LIKE LOWER("%$filter%")) 
        AND $tableName.id / ${Category.itemToCategoryIdDivisor} = $categoryId
      ''').then(
        (value) =>
            value.where((element) => allItems || element.marketGroupId != null),
      );
}
