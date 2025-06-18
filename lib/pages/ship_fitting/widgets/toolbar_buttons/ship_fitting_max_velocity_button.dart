

import 'package:provider/provider.dart';
import 'package:sweet/service/fitting_simulator.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'ship_fitting_toolbar_button.dart';

class ShipFittingMaxVelocityToolbarButton extends StatelessWidget {
  final IconData icon;
  final GestureTapCallback onTap;

  const ShipFittingMaxVelocityToolbarButton({
    super.key,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    var fitting = Provider.of<FittingSimulator>(context);
    var maxVelocity = fitting.maxFlightVelocity();

    var title = '${NumberFormat('#,##0.00').format(maxVelocity)} m/s';

    return ShipFittingToolbarButton(
      icon: icon,
      title: title,
      onTap: onTap,
    );
  }
}
