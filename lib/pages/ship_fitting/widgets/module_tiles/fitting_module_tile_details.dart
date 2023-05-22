import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:sweet/model/fitting/fitting_module.dart';
import 'package:sweet/model/ship/eve_echoes_attribute.dart';
import 'package:sweet/service/fitting_simulator.dart';
import 'package:sweet/widgets/item_attribute_value_widget.dart';

class FittingModuleTileDetails extends StatelessWidget {
  const FittingModuleTileDetails({
    Key? key,
    required this.fitting,
    required this.module,
  }) : super(key: key);

  final FittingModule module;
  final FittingSimulator fitting;

  @override
  Widget build(BuildContext context) {
    final moduleAttributes = module.baseAttributes
        .where((attr) => (attr.nameLocalisationKey ?? 0) > 0)
        .map(
          (e) => EveEchoesAttribute.values.firstWhereOrNull(
            (attr) => attr.attributeId == e.id,
          ),
        )
        .where(
          (attr) => attr != null && !kIgnoreAttributes.contains(attr),
        )
        .map((e) => e as EveEchoesAttribute);

    final uiAttributes = module.uiAttributes.where(
      (a) => !moduleAttributes.contains(a),
    );

    final attributes = [
      ...uiAttributes,
      ...moduleAttributes,
    ];

    return Column(
      children: attributes.map((e) {
        var value = fitting.getValueForItem(
          attribute: e,
          item: module,
        );
        return value != 0
            ? ItemAttributeValueWidget(
                attributeId: e.attributeId,
                attributeValue: value,
                fixedDecimals: 2,
                showAttributeId: false,
              )
            : Container();
      }).toList(),
    );
  }
}
