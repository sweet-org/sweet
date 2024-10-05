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
    final moduleAttributes = drone.baseAttributes
        .where((attr) => (attr.nameLocalisationKey ?? 0) > 0)
        .map(
          (e) => EveEchoesAttribute.values.firstWhereOrNull(
            (attr) => attr.attributeId == e.id,
          ),
        )
        .where(
          (attr) => attr != null && !kIgnoreAttributes.contains(attr),
        )
        .map((e) => e as EveEchoesAttribute)
        .toList();

    final uiAttributes = drone.uiAttributes;

    moduleAttributes.removeWhere(
      (a) => uiAttributes.contains(a),
    );

    final droneAttributes = [
      ...uiAttributes,
      ...moduleAttributes,
    ];

    final weapon = drone.fitting.modules(slotType: SlotType.high).first;

    return Column(
      children: [
        ItemDamagePattern(
          fitting: fitting,
          item: weapon,
          drone: drone,
        ),
        ...droneAttributes.map((e) {
          final droneValue = fitting.getValueForItem(
            attribute: e,
            item: drone,
          );
          final weaponValue = fitting.getValueForItem(
            attribute: e,
            item: weapon,
          );

          final value = max(weaponValue, droneValue);

          return value != 0
              ? ItemAttributeValueWidget(
                  attributeId: e.attributeId,
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
