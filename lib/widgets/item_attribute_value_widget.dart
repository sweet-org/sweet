import 'package:auto_size_text/auto_size_text.dart';
import 'package:intl/intl.dart';
import 'package:sweet/database/entities/attribute.dart';
import 'package:sweet/database/entities/unit.dart';
import 'package:sweet/repository/item_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sweet/repository/localisation_repository.dart';
import 'package:sweet/util/platform_helper.dart';

class ItemAttributeValueWidget extends StatelessWidget {
  ItemAttributeValueWidget({
    Key? key,
    required this.attributeId,
    required this.attributeValue,
    this.fixedDecimals = 2,
    this.showAttributeId = true,
    this.useSpacer = true,
    this.titleOverride,
    this.titleIdOverride,
    this.unitOverride,
    this.formulaOverride,
    this.hideIfZero = false,
    this.style,
    this.truncate = false,
  }) : super(key: key);

  final int attributeId;
  final double attributeValue;
  final int fixedDecimals;
  final bool showAttributeId;
  final bool hideIfZero;
  final bool useSpacer;
  final String? titleOverride;
  final int? titleIdOverride;
  final String? unitOverride;
  final double Function(double)? formulaOverride;
  final TextStyle? style;

  final bool truncate;

  @override
  Widget build(BuildContext context) {
    if (hideIfZero && attributeValue == 0) return Container();

    var itemRepo = RepositoryProvider.of<ItemRepository>(context);

    return FutureBuilder<Attribute?>(
      future: itemRepo.attributeWithId(id: attributeId),
      builder: (context, attrSnapshot) {
        final attribute = attrSnapshot.data;
        if (attribute == null) {
          return Container();
        }

        return FutureBuilder<Unit?>(
            future: itemRepo.unitWithId(id: attribute.unitId),
            builder: (context, unitSnapshot) {
              var localisation =
                  RepositoryProvider.of<LocalisationRepository>(context);
              var localisedName = titleIdOverride != null
                  ? localisation.getLocalisedStringForIndex(titleIdOverride)
                  : localisation.getLocalisedNameForAttribute(attribute);

              var localisedUnit =
                  localisation.getLocalisedUnitForAttribute(attribute);

              var unitString = unitOverride ??
                  unitSnapshot.data?.displayName ??
                  localisedUnit;

              var title = titleOverride ?? localisedName;

              /* ToDo: This is a temporary fix to truncate the title to fit the screen.
                       The problem is, that the AutoSizeText do not
                       truncate/wrap the text. Instead the row overflows to the
                       right causing errors.
               */
              if (truncate && title.length > 55) {
                title = "${title.substring(0, 20)}...${title.substring(
                    title.length - 25, title.length
                )}";
              }

              if (showAttributeId && PlatformHelper.isDebug) {
                title = '$title (${attribute.id})';
              }

              var finalValue = formulaOverride != null
                  ? formulaOverride!(attributeValue)
                  : attrSnapshot.data
                          ?.calculatedValue(fromValue: attributeValue) ??
                      0;

              final finalValueString =
                  NumberFormat.decimalPattern().format(finalValue);

              return Row(
                children: [
                  title.isNotEmpty
                      ? AutoSizeText(
                          title,
                          maxLines: 2,
                          wrapWords: false,
                          overflow: TextOverflow.fade,
                          style: style,
                        )
                      : Container(),
                  useSpacer
                      ? Spacer()
                      : Container(
                          width: 4,
                        ),
                  AutoSizeText(
                    '$finalValueString $unitString',
                    style: style,
                  ),
                ],
              );
            });
      },
    );
  }
}
