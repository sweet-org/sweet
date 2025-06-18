import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sweet/model/fitting/fitting_patterns.dart';
import 'package:sweet/service/fitting_simulator.dart';

class RechargeRates extends StatelessWidget {
  final FittingPattern damagePattern;
  final bool showEhp;

  const RechargeRates({
    super.key,
    required this.damagePattern,
    required this.showEhp,
  });

  @override
  Widget build(BuildContext context) {
    final fitting = RepositoryProvider.of<FittingSimulator>(context);
    final passiveShieldRate = showEhp
        ? fitting.calculateEhpPassiveShieldRate(
            damagePattern: damagePattern,
          )
        : fitting.calculatePassiveShieldRate();
    final shieldBoosterRate = showEhp
        ? fitting.calculateEhpShieldBoosterRate(
            damagePattern: damagePattern,
          )
        : fitting.calculateRawShieldBoosterRate();

    final armorRepairRate = showEhp
        ? fitting.calculateEhpArmorRepairRate(
            damagePattern: damagePattern,
          )
        : fitting.calculateRawArmorRepairRate();

    final unitString = '/ s';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 32,
              child: Image.asset('assets/icons/icon-shield.png'),
            ),
            Text('${passiveShieldRate.toStringAsFixed(2)} $unitString'),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 32,
              child: Image.asset('assets/icons/icon-shield-glow.png'),
            ),
            Text('${shieldBoosterRate.toStringAsFixed(2)} $unitString'),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 32,
              child: Image.asset('assets/icons/icon-armor-repairer.png'),
            ),
            Text('${armorRepairRate.toStringAsFixed(2)} $unitString'),
          ],
        ),
      ],
    );
  }
}
