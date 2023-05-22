

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sweet/service/fitting_simulator.dart';
import 'package:sweet/pages/ship_fitting/widgets/icon_progress_bar.dart';

class PowerUsageBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<FittingSimulator>(builder: (context, fitting, widget) {
      var value = fitting.getPowerGridUsage();
      var maxValue = fitting.getPowerGridOutput();
      return IconProgressbar(
        icon: Icon(
          Icons.power_settings_new,
          color: Colors.white,
          size: 16,
        ),
        color: value > maxValue ? Colors.red : Colors.green,
        value: maxValue > 0 ? value / maxValue : 0,
        label: '${value.toStringAsFixed(2)} / ${maxValue.toStringAsFixed(2)}',
      );
    });
  }
}
