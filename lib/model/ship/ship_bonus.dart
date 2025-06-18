import 'package:expressions/expressions.dart';

import '../../database/entities/item_modifier.dart';
import '../modifier_change_type.dart';

/*

SQL Query
SELECT 
	item_modifiers.*, 
	attributes.nameLocalisationKey AS attributeNameId, 
	attributes.unitLocalisationKey AS attributeUnitNameId, 
	attributes.attributeFormula,
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
	ORDER BY 
		id ASC
		, shipBonusCode ASC
		, shipBonusSkill ASC
) AS item ON instr(item.shipBonusCode, item_modifiers.code)
LEFT JOIN items ON bonusSkillId = items.id
LEFT JOIN attributes ON attributeId = attributes.id

*/

class ShipAttributeBonus extends ItemModifier {
  final String attributeName;
  final int attributeNameId;
  final int attributeUnitNameId;
  final String attributeFormula;
  final int bonusSkillId;
  final int? bonusSkillNameId;

  ShipAttributeBonus({
    required super.code,
    required super.typeCode,
    required super.changeType,
    required super.changeRange,
    required super.changeRangeModuleNameId,
    required super.attributeId,
    required this.attributeName,
    required super.attributeValue,
    required this.attributeNameId,
    required this.attributeUnitNameId,
    required this.attributeFormula,
    required this.bonusSkillId,
    this.bonusSkillNameId,
  }) : super(
          attributeOnly: false,
        );

  factory ShipAttributeBonus.fromJson(Map<String, dynamic> json) =>
      ShipAttributeBonus(
        code: json['code'],
        typeCode: json['typeCode'],
        changeType: changeTypeValues[json['changeType']]!,
        // attributeOnly: json['attributeOnly'],
        changeRange: json['changeRange'],
        changeRangeModuleNameId: json['changeRangeModuleNameId'],
        attributeId: json['attributeId'],
        attributeName: json['attributeName'] ?? '',
        attributeValue: json['attributeValue'],
        attributeNameId: json['attributeNameId'],
        attributeUnitNameId: json['attributeUnitNameId'],
        attributeFormula: json['attributeFormula'],
        bonusSkillId: json['bonusSkillId'],
        bonusSkillNameId: json['bonusSkillNameId'],
      );

  static final _evaluator = const ExpressionEvaluator();
  double calculatedValue() {
    // Evaluate expression
    var value = _evaluator.eval(
      Expression.parse(attributeFormula),
      {'A': attributeValue},
    );

    return value;
  }
}
