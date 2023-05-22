import '../../model/ship/ship_bonus.dart';

import '../database.dart';
import '../entities/item_modifier.dart';
import '../type_converters/type_converters.dart';

import 'base_dao.dart';
import 'base_dao_mixin.dart';

class ItemModifierDao extends BaseDao<ItemModifier> with BaseDaoMixin {
  ItemModifierDao(EveEchoesDatabase db) : super(db);

  @override
  String get tableName => 'item_modifiers';

  @override
  Map<String, TypeConverter> converters = {
    'attributeOnly': BoolTypeConverter()
  };

  @override
  Map<String, dynamic> mapItemToRow(ItemModifier item) => item.toJson();

  @override
  ItemModifier mapRowToItem(Map<String, dynamic> row) =>
      ItemModifier.fromJson(row);

  @override
  Map<String, String> get columnDefinitions => {
        'code': 'TEXT NOT NULL',
        'typeCode': 'TEXT NOT NULL',
        'changeType': 'TEXT NOT NULL',
        'attributeOnly': 'INTEGER NOT NULL',
        'changeRange': 'TEXT NOT NULL',
        'changeRangeModuleNameId': 'INTEGER NOT NULL',
        'attributeId': 'INTEGER NOT NULL',
        'attributeValue': 'REAL',
      };

  Future<Iterable<ShipAttributeBonus>> attributeBonusesForItemId(
      int itemId) async {
    var rows = await db.db.rawQuery('''
    SELECT 
      item_modifiers.*, 
      attributes.nameLocalisationKey AS attributeNameId, 
      attributes.attributeName AS attributeName, 
      attributes.unitLocalisationKey AS attributeUnitNameId, 
      attributes.attributeFormula AS attributeFormula,
      CAST(TRIM(TRIM(item.shipBonusSkill, '['), ']') AS INTEGER) AS bonusSkillId, 
      items.nameKey AS bonusSkillNameId 
    FROM 
      item_modifiers
    JOIN (
      WITH RECURSIVE neat(
        id, shipBonusCode, etc, shipBonusSkill, etc2
      ) AS(
        SELECT
          id
          , ''
          , shipBonusCodeList || ','
          , ''
          , shipBonusSkillList || ','
        FROM (SELECT id, shipBonusCodeList, shipBonusSkillList FROM items WHERE id = $itemId)
        WHERE id
        UNION ALL

        SELECT 
          id
          , SUBSTR(etc, 0, INSTR(etc, ','))
          , SUBSTR(etc, INSTR(etc, ',')+1)
          , SUBSTR(etc2, 0, INSTR(etc2, ','))
          , SUBSTR(etc2, INSTR(etc2, ',')+1)
        FROM neat
        WHERE etc <> ''
      )

      SELECT id, shipBonusCode, shipBonusSkill FROM neat
      WHERE shipBonusCode <> ''
    ) AS item ON instr(item.shipBonusCode, item_modifiers.code)
    LEFT JOIN items ON bonusSkillId = items.id
    LEFT JOIN attributes ON attributeId = attributes.id
    ''');
    return rows.map((row) => ShipAttributeBonus.fromJson(row));
  }
}
