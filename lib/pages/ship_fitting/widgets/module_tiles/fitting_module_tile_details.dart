import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:sweet/model/fitting/fitting_module.dart';
import 'package:sweet/model/ship/eve_echoes_attribute.dart';
import 'package:sweet/service/fitting_simulator.dart';
import 'package:sweet/widgets/item_attribute_value_widget.dart';
import 'package:sweet/widgets/item_damage_pattern.dart';

class FittingModuleTileDetails extends StatelessWidget {
  const FittingModuleTileDetails({
    super.key,
    required this.fitting,
    required this.module,
  });

  final FittingModule module;
  final FittingSimulator fitting;

  @override
  Widget build(BuildContext context) {
    final moduleAttributes = module.baseAttributes
        .where((attr) => (attr.nameLocalisationKey ?? 0) > 0)
        .map((attr) => attr.id)
        .map((attrId) {
      final attr = EveEchoesAttributeOrId(orId: attrId);
      if (attr.attribute != null &&
          kIgnoreAttributes.contains(attr.attribute!)) {
        return null;
      }
      return attr;
    }).whereNotNull();

    final uiAttributes = module.uiAttributes
        .map((a) => EveEchoesAttributeOrId(attribute: a))
        .where(
          (a) => !moduleAttributes.contains(a),
        );

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
          var value = fitting.getValueForItemWithAttrOrId(
            attrOrId: e,
            item: module,
          );
          return value != 0
              ? ItemAttributeValueWidget(
                  attributeId: e.id,
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
