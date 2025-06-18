import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sweet/model/ship/eve_echoes_attribute.dart';
import 'package:sweet/service/fitting_simulator.dart';
import 'package:sweet/widgets/item_attribute_value_widget.dart';

class ShipAttributeValue extends StatelessWidget {
  final EveEchoesAttribute attribute;
  final String? titleOverride;
  final bool hideIfZero;

  const ShipAttributeValue({
    super.key,
    required this.attribute,
    this.titleOverride,
    this.hideIfZero = false,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<FittingSimulator>(
      builder: (context, fitting, widget) {
        final value = fitting.getValueForShip(attribute: attribute);
        if (hideIfZero && value == 0) return Container();

        return Container(
          margin: EdgeInsets.all(4),
          child: ItemAttributeValueWidget(
            fixedDecimals: 2,
            showAttributeId: false,
            attributeId: attribute.attributeId,
            titleOverride: titleOverride,
            attributeValue: value,
            hideIfZero: hideIfZero,
          ),
        );
      },
    );
  }
}
