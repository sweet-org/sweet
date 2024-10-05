import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:sweet/model/fitting/fitting_module.dart';
import 'package:sweet/model/ship/eve_echoes_attribute.dart';
import 'package:sweet/service/fitting_simulator.dart';
import 'package:sweet/widgets/item_attribute_value_widget.dart';
import 'package:sweet/widgets/item_damage_pattern.dart';

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
        .map((attr) => attr.id)
        .where(
      (attrId) {
        final attr = EveEchoesAttribute.values.firstWhereOrNull(
          (e) => e.attributeId == attrId,
        );
        return attr == null || !kIgnoreAttributes.contains(attr);
      },
    );

    final uiAttributes = module.uiAttributes
        .where(
          (a) => !moduleAttributes.contains(a.attributeId),
        )
        .map((a) => a.attributeId);

    final attributes = [
      ...uiAttributes,
      ...moduleAttributes,
    ];

    return Column(
      children: [
        ItemDamagePattern(
          fitting: fitting,
          item: module,
        ),
        ...attributes.map((e) {
          var value = fitting.getValueForItemWithAttributeId(
            attributeId: e,
            item: module,
          );
          return value != 0
              ? ItemAttributeValueWidget(
                  attributeId: e,
                  attributeValue: value,
                  fixedDecimals: 2,
                  showAttributeId: false,
                )
              : Container();
        })
      ],
    );
  }
}
