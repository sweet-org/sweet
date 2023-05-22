import '../database.dart';
import 'base_dao.dart';
import 'base_dao_mixin.dart';

import '../type_converters/type_converters.dart';
import '../entities/item_attribute_value.dart';

class ItemAttributeDao extends BaseDao<ItemAttributeValue> with BaseDaoMixin {
  ItemAttributeDao(EveEchoesDatabase db) : super(db);

  @override
  String get tableName => 'item_attributes';

  @override
  Map<String, TypeConverter> converters = {};

  @override
  Map<String, dynamic> mapItemToRow(ItemAttributeValue item) => item.toJson();

  @override
  ItemAttributeValue mapRowToItem(Map<String, dynamic> row) =>
      ItemAttributeValue.fromJson(row);

  @override
  Map<String, String> get columnDefinitions => {
        'itemId': 'INTEGER NOT NULL',
        'attributeId': 'INTEGER NOT NULL',
        'value': 'REAL NOT NULL'
      };

  @override
  String get tableConstraint => 'PRIMARY KEY(itemId, attributeId)';

  Future<double?> valueForItem({
    required int itemId,
    required int attributeId,
  }) async {
    var results = await select(
      whereClause: 'WHERE itemId = $itemId AND attributeId = $attributeId',
    );

    if (results.isEmpty) return null;

    if (results.length > 1) {
      print('Multiple results returned! ${results.length}');
    }

    return results.first.value;
  }

  Future<Iterable<ItemAttributeValue>> selectForItem(
          {required int itemId}) async =>
      await select(whereClause: 'WHERE itemId = $itemId');
}
