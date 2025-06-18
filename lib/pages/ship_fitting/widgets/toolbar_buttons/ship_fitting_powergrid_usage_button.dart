

import 'package:provider/provider.dart';
import 'package:sweet/service/fitting_simulator.dart';
import 'package:sweet/pages/ship_fitting/widgets/toolbar_buttons/ship_fitting_toolbar_button.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ShipFittingPowergridUsageButton extends StatelessWidget {
  final IconData icon;
  final GestureTapCallback onTap;

  const ShipFittingPowergridUsageButton(
      {super.key, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    var fitting = Provider.of<FittingSimulator>(context);
    var title = NumberFormat('##0.00 %')
        .format(fitting.calculatePowerGridUtilisation());

    return ShipFittingToolbarButton(
      icon: icon,
      title: title.trim(),
      onTap: onTap,
    );
  }
}
