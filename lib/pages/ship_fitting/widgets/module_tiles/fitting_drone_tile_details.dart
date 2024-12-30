import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sweet/model/fitting/fitting_drone.dart';
import 'package:sweet/model/fitting/fitting_patterns.dart';
import 'package:sweet/model/ship/eve_echoes_attribute.dart';
import 'package:sweet/model/ship/slot_type.dart';
import 'package:sweet/pages/ship_fitting/widgets/defence_widgets/defence_resistances.dart';
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

  static const kShieldAttrs = [
    EveEchoesAttribute.shieldEmDamageResonance,
    EveEchoesAttribute.shieldThermalDamageResonance,
    EveEchoesAttribute.shieldKineticDamageResonance,
    EveEchoesAttribute.shieldExplosiveDamageResonance
  ];
  static const kArmorAttrs = [
    EveEchoesAttribute.armorEmDamageResonance,
    EveEchoesAttribute.armorThermalDamageResonance,
    EveEchoesAttribute.armorKineticDamageResonance,
    EveEchoesAttribute.armorExplosiveDamageResonance
  ];
  static const kHullAttrs = [
    EveEchoesAttribute.hullEmDamageResonance,
    EveEchoesAttribute.hullThermalDamageResonance,
    EveEchoesAttribute.hullKineticDamageResonance,
    EveEchoesAttribute.hullExplosiveDamageResonance
  ];
  static const kResistanceAttrs = [
    ...kShieldAttrs,
    ...kArmorAttrs,
    ...kHullAttrs,
  ];

  @override
  Widget build(BuildContext context) {
    final weapon = drone.fitting.modules(slotType: SlotType.high).first;

    final moduleAttributes = [...drone.baseAttributes, ...weapon.baseAttributes]
        .where((attr) => (attr.nameLocalisationKey ?? 0) > 0)
        .map((attr) => attr.id)
        .map((attrId) {
      final attr = EveEchoesAttributeOrId(orId: attrId);
      if (attr.attribute != null) {
        if (kIgnoreAttributes.contains(attr.attribute!) ||
            kResistanceAttrs.contains(attr.attribute!)) {
          return null;
        }
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
        Divider(),
        Text("Drone Defence"),
        ChangeNotifierProvider<FittingSimulator>.value(
          value: drone.fitting,
          child: DefenceResistances(
              rowHeight: 24,
              rowMargin: 0,
              damagePattern: FittingPattern.uniform,
              onEhpToggle: (show) {}),
        ),
        Divider(),
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
