import 'dart:async';

import 'package:collection/collection.dart';
import '../entities/item_nanocore_affix.dart';

import '../type_converters/type_converters.dart';
import 'base_dao.dart';
import 'base_dao_mixin.dart';

class ItemNanocoreAffixDao extends BaseDao<ItemNanocoreAffix>
    with BaseDaoMixin {
  ItemNanocoreAffixDao(super.db);

  @override
  String get tableName => 'item_nanocore_affix';

  @override
  Map<String, TypeConverter> converters = {};

  @override
  Map<String, dynamic> mapItemToRow(ItemNanocoreAffix item) => item.toJson();

  @override
  ItemNanocoreAffix mapRowToItem(Map<String, dynamic> row) =>
      ItemNanocoreAffix.fromJson(row);

  @override
  List<String> get ignoreKeys => [
        'children',
        'item',
      ];

  @override
  Map<String, String> get columnDefinitions => {
        'attrId': 'INTEGER NOT NULL PRIMARY KEY',
        'attrFirstClass': 'INTEGER NOT NULL',
        'attrSecondClass': 'INTEGER NOT NULL',
        'attrGroup': 'INTEGER NOT NULL',
        'attrLevel': 'INTEGER NOT NULL',
        'attrCount': 'INTEGER NOT NULL',
      };

  Future<ItemNanocoreAffix?> selectForAttr({required int attrId}) async =>
      (await select(whereClause: 'WHERE attrId = $attrId')).firstOrNull;
}
