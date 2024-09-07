import 'dart:async';

import 'package:collection/collection.dart';

import '../database.dart';
import 'base_dao.dart';
import 'base_dao_mixin.dart';

import '../type_converters/type_converters.dart';

import '../entities/item_nanocore.dart';

class ItemNanocoreDao extends BaseDao<ItemNanocore> with BaseDaoMixin {
  ItemNanocoreDao(EveEchoesDatabase db) : super(db);

  @override
  String get tableName => 'item_nanocores';

  @override
  Map<String, TypeConverter> converters = {
    'availableShips': IntListTypeConverter(),
    'selectableModifierItems': IntListTypeConverter(),
    'trainableModifierItems': IntListListTypeConverter(),
    'isGold': BoolTypeConverter(),
  };

  @override
  Map<String, dynamic> mapItemToRow(ItemNanocore item) => item.toJson();

  @override
  ItemNanocore mapRowToItem(Map<String, dynamic> row) =>
      ItemNanocore.fromJson(row);

  @override
  Map<String, String> get columnDefinitions => {
        'itemId': 'INTEGER NOT NULL',
        'filmGroup': 'TEXT NOT NULL',
        'filmQuality': 'INTEGER NOT NULL',
        'isGold': 'INTEGER NOT NULL',
        'otherItemId': 'INTEGER NOT NULL',
        'availableShips': 'TEXT NOT NULL',
        'selectableModifierItems': 'TEXT NOT NULL',
        'trainableModifierItems': 'TEXT NOT NULL',
      };

  @override
  String get tableConstraint => 'PRIMARY KEY(itemId)';

  Future<ItemNanocore?> selectForItem({required int itemId}) async =>
      (await select(whereClause: 'WHERE itemId = $itemId')).firstOrNull;
}
