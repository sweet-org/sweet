import 'dart:async';

import 'base_dao.dart';
import 'base_dao_mixin.dart';

import '../type_converters/type_converters.dart';

import '../entities/item_effect.dart';

class ItemEffectDao extends BaseDao<ItemEffect> with BaseDaoMixin {
  ItemEffectDao(super.db);

  @override
  String get tableName => 'item_effects';

  @override
  Map<String, TypeConverter> converters = {'isDefault': BoolTypeConverter()};

  @override
  Map<String, dynamic> mapItemToRow(ItemEffect item) => item.toJson();

  @override
  ItemEffect mapRowToItem(Map<String, dynamic> row) => ItemEffect.fromJson(row);

  @override
  Map<String, String> get columnDefinitions => {
        'itemId': 'INTEGER NOT NULL',
        'effectId': 'INTEGER NOT NULL',
        'isDefault': 'INTEGER NOT NULL DEFAULT 0',
      };

  @override
  String get tableConstraint => 'PRIMARY KEY(itemId, effectId)';

  Future<int?> getDefaultEffectId({required int itemId}) async {
    var results = await db.db.rawQuery(
        'SELECT effectId FROM $tableName WHERE itemId = $itemId AND isDefault = 1');

    if (results.isEmpty) return null;

    return results.first['effectId'] as FutureOr<int?>;
  }

  Future<Iterable<ItemEffect>> selectForItem({required int itemId}) async =>
      await select(whereClause: 'WHERE itemId = $itemId');
}
