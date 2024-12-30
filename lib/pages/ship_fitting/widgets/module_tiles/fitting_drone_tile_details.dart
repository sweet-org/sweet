import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:sweet/model/fitting/fitting_drone.dart';
import 'package:sweet/model/ship/eve_echoes_attribute.dart';
import 'package:sweet/model/ship/slot_type.dart';
import 'package:sweet/service/fitting_simulator.dart';
import 'package:sweet/widgets/item_attribute_value_widget.dart';
import 'package:sweet/widgets/item_damage_pattern.dart';

class FittingDroneTileDetails extends StatelessWidget {
  const FittingDroneTileDetails({
    Key? key,
    required this.fitting,
    required this.drone,
  }) : super(key: key);

  final FittingDrone drone;
  final FittingSimulator fitting;

  @override
  Widget build(BuildContext context) {
    final weapon = drone.fitting.modules(slotType: SlotType.high).first;

    final moduleAttributes = [...drone.baseAttributes, ...weapon.baseAttributes]
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

    final uiAttributes = drone.uiAttributes
        .map((a) => EveEchoesAttributeOrId(attribute: a))
        .where(
          (a) => !moduleAttributes.contains(a),
        );

    final droneAttributes = [
      ...uiAttributes,
      ...moduleAttributes,
    ];

    final count = fitting.getValueForItem(
        attribute: EveEchoesAttribute.fighterNumberLimit, item: drone);

    return Column(
      children: [
        ItemDamagePattern(
          fitting: fitting,
          drone: drone,
          droneCount: count.toInt(),
        ),
        ...droneAttributes.map((e) {
          final droneValue = fitting.getValueForItemWithAttrOrId(
            attrOrId: e,
            item: drone,
          );
          final weaponValue = drone.fitting.getValueForItemWithAttrOrId(
            attrOrId: e,
            item: weapon,
          );

          final value = max(weaponValue, droneValue);

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
