

import 'package:flutter/material.dart';
import 'package:sweet/model/ship/eve_echoes_attribute.dart';
import 'package:sweet/service/fitting_simulator.dart';
import 'package:sweet/widgets/item_attribute_value_widget.dart';

class ShipFittingStatsDrawer extends StatelessWidget {
  final FittingSimulator fitting;

  const ShipFittingStatsDrawer({
    super.key,
    required this.fitting,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 600,
      color: Theme.of(context).canvasColor,
      child: ListView.builder(
        itemCount: EveEchoesAttribute.values.length,
        itemBuilder: (context, index) {
          var attribute = EveEchoesAttribute.values[index];

          var attributeValue = fitting.getValueForItem(
            item: fitting.ship,
            attribute: attribute,
          );

          return attributeValue > 0
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ItemAttributeValueWidget(
                    attributeId: attribute.attributeId,
                    attributeValue: attributeValue,
                    showAttributeId: false,
                    fixedDecimals: 2,
                  ),
                )
              : Container();
        },
      ),
    );
  }
}
