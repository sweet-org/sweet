import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sweet/model/ship/ship_bonus.dart';
import 'package:sweet/repository/localisation_repository.dart';
import 'package:sweet/util/localisation_constants.dart';

class ShipBonusWidget extends StatelessWidget {
  final int bonusSkillNameId;
  final Iterable<ShipAttributeBonus> bonuses;

  const ShipBonusWidget(
      {Key? key, required this.bonusSkillNameId, required this.bonuses})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localisation = RepositoryProvider.of<LocalisationRepository>(context);
    String title;

    if (bonusSkillNameId == 0) {
      title = localisation
          .getLocalisedStringForIndex(LocalisationStrings.roleBonus);
    } else {
      title =
          '${localisation.getLocalisedStringForIndex(bonusSkillNameId)}${localisation.getLocalisedStringForIndex(LocalisationStrings.bonusPerLv)}';
    }

    return Card(
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title),
            Divider(),
            for (var bonus in bonuses) _buildBonusWidget(bonus, context),
          ],
        ),
      ),
    );
  }

  Widget _buildBonusWidget(ShipAttributeBonus bonus, BuildContext context) {
    final localisation = RepositoryProvider.of<LocalisationRepository>(context);

    // Title builds by change range item (tips_attrs) + attribute name
    final moduleName =
        localisation.getLocalisedStringForIndex(bonus.changeRangeModuleNameId);
    final attributeName = bonus.attributeNameId > 0
        ? localisation.getLocalisedStringForIndex(bonus.attributeNameId)
        : bonus.attributeName;
    final attributeUnit =
        localisation.getLocalisedStringForIndex(bonus.attributeUnitNameId);

    final bonusValue = bonus.calculatedValue();
    var bonusAmount = '${bonusValue.toStringAsFixed(2)}$attributeUnit';

    if (!bonusValue.isNegative) {
      bonusAmount = '+$bonusAmount';
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          bonusAmount,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          '$moduleName $attributeName'.trim(),
          style: TextStyle(
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}


  /*

  Values needed:
  - Attr ID
  - Attr Name ID
  - Attr Amount
  - Attr Formula
  - Attr Unit
  - Module name (from tips <=> change_range)

  Query is:

SELECT modifier_definition.code, modifier_definition.changeRanges, modifier_definition.changeRangeModuleNames, modifier_definition.attributeIds, modifier_value.attributes AS amounts
FROM modifier_definition 
JOIN (SELECT id, shipBonusCodeList, shipBonusSkillList FROM items WHERE id = 10100000308) AS item ON instr(item.shipBonusCodeList, modifier_definition.code)
LEFT JOIN modifier_value ON modifier_value.typeName = modifier_definition.code

  ----
  Test Data

  SELECT modifier_definition.code, modifier_definition.attributeIds, modifier_value.attributes AS amounts
  FROM modifier_definition 
  LEFT JOIN modifier_value ON modifier_value.typeName = modifier_definition.code
  WHERE modifier_definition.code LIKE "%/ShipBonus/刽子手级II%"

  "/ShipBonus/刽子手级II2/": {
      "attribute_ids": [
          2002,
          2027
      ],
      "attribute_only": false,
      "change_ranges": [
          "/Ener/TSizeS/",
          "/Ener/TSizeS/"
      ],
      "change_types": [
          "module",
          "module"
      ]
  },
  */