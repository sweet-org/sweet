import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sweet/model/fitting/fitting_patterns.dart';
import 'package:sweet/model/ship/eve_echoes_attribute.dart';
import 'package:sweet/service/fitting_simulator.dart';
import 'package:sweet/util/constants.dart';

import '../attribute_progress_bar.dart';

class ResistanceRow extends StatelessWidget {
  const ResistanceRow({
    Key? key,
    required this.showEHP,
    required this.rowHeight,
    required this.rowAttribute,
    required this.resistanceAttributes,
    required this.damagePattern,
    this.margin = 2,
  }) : super(key: key);

  final EveEchoesAttribute rowAttribute;
  final List<EveEchoesAttribute> resistanceAttributes;
  final bool showEHP;
  final double rowHeight;
  final FittingPattern damagePattern;
  final double margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: margin),
      child: Consumer<FittingSimulator>(builder: (context, fitting, widget) {
        var resistanceValues = resistanceAttributes
            .map((e) => fitting.getValueForShip(attribute: e))
            .toList();

        final rowTotal = showEHP
            ? fitting.calculateEHPForAttribute(
                hpAttribute: rowAttribute,
                damagePattern: damagePattern,
              )
            : fitting.rawHPForAttribute(
                hpAttribute: rowAttribute,
              );

        final rowTotalString =
            NumberFormat(StringFormats.twoDecimalPlaces).format(rowTotal);
        return Row(
          children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: 2),
              child: Image.asset(
                rowAttribute.iconName!,
                height: rowHeight,
              ),
            ),
            for (int i = 0; i < resistanceValues.length; i++)
              Expanded(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 2),
                  height: rowHeight,
                  child: AttributeProgressBar(
                    height: rowHeight,
                    inverted: true,
                    formulaOverride: (value) => value * 100,
                    unitOverride: '%',
                    attribute: resistanceAttributes[i],
                    attributeValue: resistanceValues.elementAt(i),
                  ),
                ),
              ),
            Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 2),
                alignment: Alignment.center,
                height: rowHeight,
                child: Text(
                  rowTotalString,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
