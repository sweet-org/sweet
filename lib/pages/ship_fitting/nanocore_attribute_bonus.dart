import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sweet/database/database_exports.dart';
import 'package:sweet/database/entities/attribute.dart';
import 'package:sweet/model/fitting/fitting_nanocore_attribute.dart';
import 'package:sweet/repository/item_repository.dart';
import 'package:sweet/repository/localisation_repository.dart';

typedef SelectedModifierCallback = void Function(
  FittingNanocoreAttribute? modifier,
  NanocoreAttributeLevel? level,
);

class NanocoreAttributeBonus extends StatelessWidget {
  final FittingNanocoreAttribute nanocoreAttribute;

  final SelectedModifierCallback onTap;

  NanocoreAttributeBonus({
    super.key,
    required this.nanocoreAttribute,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final localisation = RepositoryProvider.of<LocalisationRepository>(context);
    final itemRepo = RepositoryProvider.of<ItemRepository>(context);

    final attributeId = nanocoreAttribute.attributeId;
    final changeRangeModuleNameId = nanocoreAttribute.changeRangeModuleNameId;

    return FutureBuilder<Attribute?>(
      future: itemRepo.attributeWithId(id: attributeId),
      builder: (context, snapshot) {
        final attribute = snapshot.data;
        if (attribute == null) {
          return CircularProgressIndicator();
        }
        // Title builds by change range item (tips_attrs) + attribute name
        final moduleName =
            localisation.getLocalisedStringForIndex(changeRangeModuleNameId);

        final attributeName =
            localisation.getLocalisedNameForAttribute(attribute);

        final attributeUnit =
            localisation.getLocalisedUnitForAttribute(attribute);

        final values = nanocoreAttribute.hasRange
            ? [
                nanocoreAttribute.minValue,
                nanocoreAttribute.maxValue,
              ]
            : [
                nanocoreAttribute.minValue,
              ];
        final bonusAmountString = values.map(
          (e) {
            return formatValueToString(attribute, e, attributeUnit);
          },
        ).join(' - ');

        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            buildLevelSelector(
              context,
              bonusAmountString: bonusAmountString,
              attribute: attribute,
              attributeUnit: attributeUnit,
            ),
            Expanded(
              child: Center(
                child: AutoSizeText(
                  '$moduleName $attributeName'.trim(),
                  minFontSize: 10,
                  maxFontSize: 14,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  String formatValueToString(
      Attribute attribute, double e, String attributeUnit) {
    final bonusValue = attribute.calculatedValue(fromValue: e);
    return '${bonusValue.isNegative ? '' : '+'}${bonusValue.toStringAsFixed(2)}$attributeUnit';
  }

  Widget buildLevelSelector(
    BuildContext context, {
    required String bonusAmountString,
    required Attribute attribute,
    required String attributeUnit,
  }) {
    if (nanocoreAttribute.levels.length == 1) {
      return AutoSizeText(
        bonusAmountString,
        minFontSize: 16,
        maxFontSize: 20,
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      );
    }
    return DropdownButton<NanocoreAttributeLevel>(
      isDense: true,
      iconSize: 16,
      hint: Text(bonusAmountString),
      alignment: AlignmentDirectional.center,
      value: nanocoreAttribute.selectedLevel,
      onChanged: (e) => onTap(nanocoreAttribute, e),
      selectedItemBuilder: (context) => nanocoreAttribute.levels
          .map(
            (e) => AutoSizeText(
              formatValueToString(
                attribute,
                e.value.attributeValue,
                attributeUnit,
              ),
              minFontSize: 16,
              maxFontSize: 20,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          )
          .toList(),
      items: nanocoreAttribute.levels
          .map(
            (e) => DropdownMenuItem(
              value: e,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      formatValueToString(
                        attribute,
                        e.value.attributeValue,
                        attributeUnit,
                      ),
                    ),
                  ),
                  Text(
                    '${(e.chance * 100).toStringAsFixed(2)}%',
                    textAlign: TextAlign.right,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontSize: 12,
                        ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}
