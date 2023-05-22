
import '../database.dart';

import 'base_dao.dart';
import 'base_dao_mixin.dart';

import '../type_converters/type_converters.dart';

import '../entities/attribute.dart';

class AttributeDao extends BaseDao<Attribute> with BaseDaoMixin {
  AttributeDao(EveEchoesDatabase db) : super(db);

  @override
  String get tableName => 'attributes';

  @override
  List<String> get ignoreKeys => [
        'baseValue',
      ];

  @override
  Map<String, TypeConverter> converters = {
    'attributeOperator': IntListTypeConverter(),
    'toAttrId': IntListTypeConverter(),
    'available': BoolTypeConverter(),
    'highIsGood': BoolTypeConverter(),
    'stackable': BoolTypeConverter(),
  };

  @override
  Map<String, dynamic> mapItemToRow(Attribute item) => item.toJson();

  @override
  Attribute mapRowToItem(Map<String, dynamic> row) => Attribute.fromJson(row);

  @override
  Map<String, String> get columnDefinitions => {
        'id': 'INTEGER NOT NULL PRIMARY KEY',
        'attributeCategory': 'INTEGER NOT NULL',
        'attributeName': 'TEXT NOT NULL',
        'available': 'INTEGER NOT NULL',
        'chargeRechargeTimeId': 'INTEGER NOT NULL',
        'defaultValue': 'REAL NOT NULL',
        'highIsGood': 'INTEGER NOT NULL',
        'maxAttributeId': 'INTEGER NOT NULL',
        'attributeOperator': 'TEXT NOT NULL',
        'stackable': 'INTEGER NOT NULL',
        'toAttrId': 'TEXT NOT NULL',
        'unitId': 'INTEGER NOT NULL',
        'unitLocalisationKey': 'INTEGER DEFAULT 0',
        'attributeSourceUnit': 'TEXT DEFAULT ""',
        'attributeTip': 'TEXT DEFAULT ""',
        'attributeSourceName': 'TEXT DEFAULT ""',
        'nameLocalisationKey': 'INTEGER DEFAULT 0',
        'tipLocalisationKey': 'INTEGER DEFAULT 0',
        'attributeFormula': 'TEXT NOT NULL DEFAULT "A"',
      };

  Future<Iterable<Attribute>> getBaseAttributesForItem(int itemId,
      {bool complete = true}) async {
    final selectParams = complete
        ? 'item_attributes.value as baseValue, attributes.*'
        : 'item_attributes.value as baseValue, attributes.id, attributes.attributeFormula, attributes.toAttrId, attributes.attributeOperator, attributes.highIsGood';
    return select_raw(query: '''
        SELECT $selectParams
        FROM item_attributes 
        LEFT JOIN attributes ON item_attributes.attributeId = attributes.id
        WHERE itemId = $itemId''');
  }
}
