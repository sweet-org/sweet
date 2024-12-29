import 'package:flutter/widgets.dart';
import 'package:sweet/model/fitting/fitting_drone.dart';

import 'package:sweet/model/ship/eve_echoes_attribute.dart';
import 'package:sweet/service/fitting_simulator.dart';

import '../model/fitting/fitting_item.dart';

final damageAttributes = [
  EveEchoesAttribute.emDamage,
  EveEchoesAttribute.thermalDamage,
  EveEchoesAttribute.kineticDamage,
  EveEchoesAttribute.explosiveDamage,
];

class ItemDamagePattern extends StatelessWidget {

  late final Map<EveEchoesAttribute, double> damagePattern;
  final FittingSimulator? fitting;
  final bool hideIfZero;

  ItemDamagePattern({
    this.hideIfZero = true,
    Map<EveEchoesAttribute, double>? damagePattern,
    this.fitting,
    FittingItem? item,
    FittingItem? drone,
    int droneCount = 1,
  }) {
    if (damagePattern != null) {
      this.damagePattern = damagePattern;
    } else {
      this.damagePattern = Map.fromEntries(damageAttributes.map((e) {
        final itemValue = item != null
            ? fitting?.getValueForItem(
                attribute: e,
                item: item,
              )
            : null;
        final droneValue = drone != null
            ? (drone as FittingDrone)
                .fitting
                .calculateTotalAlphaStrike(damageType: e)
            : null;
        return MapEntry(e, (itemValue ?? 0.0) + (droneValue ?? 0.0) * droneCount);
      }));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (hideIfZero && damagePattern.values.every((element) => element == 0.0)) {
      return Container();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Row(
        children: damageAttributes
            .map((e) {
          final value = damagePattern[e] ?? 0.0;
          return [
            Row(
              children: [
                Image.asset(
                  e.iconName!,
                  width: 20,
                  height: 20,
                ),
                Text(
                  value.toStringAsFixed(2),
                ),
              ],
            ),
            Spacer(),
          ];
        })
            .expand((e) => e)
            .toList(),
      ),
    );
  }
}
