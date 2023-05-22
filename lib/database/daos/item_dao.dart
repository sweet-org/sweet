import '../database.dart';
import 'base_dao.dart';
import 'base_dao_mixin.dart';

import '../type_converters/type_converters.dart';

import '../entities/item.dart';
import '../entities/category.dart';

class ItemDao extends BaseDao<Item> with BaseDaoMixin {
  ItemDao(EveEchoesDatabase db) : super(db);

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
      await select(whereClause: 'WHERE id / 1000000000 = $categoryId');

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

  Future<Iterable<Item>> filterOnNameAndMarketGroup(
          {required String filter,
          required String languageCode,
          required int marketGroupId}) async =>
      await select_raw(query: '''
      SELECT $tableName.*, ${db.localisedStringDao.tableName}.$languageCode AS langString, ${db.localisedStringDao.tableName}.source AS sourceString
      FROM $tableName
      LEFT JOIN ${db.localisedStringDao.tableName} ON $tableName.nameKey = ${db.localisedStringDao.tableName}.id
      WHERE (LOWER(langString) LIKE LOWER("%$filter%") OR LOWER(sourceString) LIKE LOWER("%$filter%")) AND marketGroupId / 100000 = $marketGroupId
      ''');

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
