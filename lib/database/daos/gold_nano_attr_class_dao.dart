import 'dart:async';

import 'package:collection/collection.dart';

import '../entities/gold_nano_attr_class.dart';
import '../type_converters/type_converters.dart';
import 'base_dao.dart';
import 'base_dao_mixin.dart';

class GoldNanoAttrClassDao extends BaseDao<GoldNanoAttrClass>
    with BaseDaoMixin {
  GoldNanoAttrClassDao(super.db);

  @override
  String get tableName => 'gold_nano_attr_class';

  @override
  Map<String, TypeConverter> converters = {};

  @override
  Map<String, dynamic> mapItemToRow(GoldNanoAttrClass item) => item.toJson();

  @override
  GoldNanoAttrClass mapRowToItem(Map<String, dynamic> row) =>
      GoldNanoAttrClass.fromJson(row);

  @override
  List<String> get ignoreKeys => [
        'children',
        'items',
      ];

  @override
  Map<String, String> get columnDefinitions => {
        'classId': 'INTEGER NOT NULL',
        'classLevel': 'INTEGER NOT NULL',
        'parentClassId': 'INTEGER NOT NULL',
        'sourceName': 'TEXT NOT NULL',
        'nameKey': 'INTEGER NOT NULL',
      };

  @override
  String get tableConstraint => 'PRIMARY KEY(classId, classLevel)';

  Future<GoldNanoAttrClass?> selectForFirstClass({required int classId}) async =>
      (await select(whereClause: 'WHERE attrId = $classId AND classLevel=1')).firstOrNull;

  Future<GoldNanoAttrClass?> selectForSecondClass({required int classId}) async =>
      (await select(whereClause: 'WHERE attrId = $classId AND classLevel=2')).firstOrNull;
}
