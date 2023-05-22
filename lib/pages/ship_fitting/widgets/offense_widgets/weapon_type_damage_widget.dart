import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sweet/service/fitting_simulator.dart';
import 'package:sweet/model/ship/weapon_type.dart';

class WeaponTypeDamageWidget extends StatelessWidget {
  final WeaponType weaponType;
  final double iconSize;

  WeaponTypeDamageWidget({
    required this.weaponType,
    this.iconSize = 64,
  });

  String get iconPath {
    switch (weaponType) {
      case WeaponType.turret:
        return 'assets/icons/icon-turret.png';
      case WeaponType.missile:
        return 'assets/icons/icon-missiles.png';
      case WeaponType.drone:
        return 'assets/icons/icon-drones.png';
      case WeaponType.all:
        return 'assets/icons/icon-burst.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FittingSimulator>(
      builder: (context, fitting, widget) {
        var dps = 0.0;
        var alpha = 0.0;
        if (weaponType == WeaponType.all) {
          dps = fitting.calculateTotalDps();
          alpha = fitting.calculateTotalAlphaStrike();
        } else {
          dps = fitting.calculateTotalDpsForModules(weaponType: weaponType);
          alpha = fitting.calculateTotalAlphaStrikeForModules(
              weaponType: weaponType);
        }
        var totalDps = NumberFormat('#,##0.00').format(dps);
        var totalAlpha = NumberFormat('#,##0.00').format(alpha);

        return Container(
          margin: EdgeInsets.all(2),
          child: Column(
            children: [
              Image.asset(
                iconPath,
                height: iconSize,
              ),
              Text(totalDps),
              Text(totalAlpha),
            ],
          ),
        );
      },
    );
  }
}
