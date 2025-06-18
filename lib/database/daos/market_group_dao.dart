

import 'base_dao.dart';
import 'base_dao_mixin.dart';

import '../type_converters/type_converters.dart';

import '../entities/market_group.dart';

class MarketGroupDao extends BaseDao<MarketGroup> with BaseDaoMixin {
  MarketGroupDao(super.db);

  @override
  String get tableName => 'market_group';

  @override
  Map<String, TypeConverter> converters = {};

  @override
  List<String> get ignoreKeys => [
        'children',
        'items',
      ];

  @override
  Map<String, dynamic> mapItemToRow(MarketGroup item) => item.toJson();

  @override
  MarketGroup mapRowToItem(Map<String, dynamic> row) =>
      MarketGroup.fromJson(row);

  @override
  Map<String, String> get columnDefinitions => {
        'id': 'INTEGER PRIMARY KEY',
        'parentId': 'INTEGER',
        'children': '',
        'items': '',
        'iconIndex': 'INTEGER',
        'localisationIndex': 'INTEGER',
        'sourceName': 'TEXT',
      };
}
