

import 'package:provider/provider.dart';
import 'package:sweet/service/fitting_simulator.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'ship_fitting_toolbar_button.dart';

class ShipFittingDPSToolbarButton extends StatelessWidget {
  final IconData icon;
  final GestureTapCallback onTap;

  const ShipFittingDPSToolbarButton({Key? key, required this.icon, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var fitting = Provider.of<FittingSimulator>(context);

    var title = NumberFormat('#,##0.00').format(fitting.calculateTotalDps());
    return ShipFittingToolbarButton(
      icon: icon,
      title: title.trim(),
      onTap: onTap,
    );
  }
}
