import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sweet/service/fitting_simulator.dart';

import '../../../../widgets/gradient_slider_shape.dart';

final rateGradient = LinearGradient(colors: [
  Colors.red,
  Colors.orange,
  Colors.green,
  Colors.orange,
  Colors.red,
], stops: [
  0.0,
  0.0125,  //~100% Recharge rate
  0.25,   //~250% Recharge rate
  0.785,  //~100% Recharge rate
  1.0,
]);

class ShieldSelectSlider extends StatefulWidget {
  const ShieldSelectSlider({
    super.key,
  });

  @override
  State<ShieldSelectSlider> createState() => _ShieldSelectSliderState();
}

class _ShieldSelectSliderState extends State<ShieldSelectSlider> {
  double currentShieldPercentage = 0.25;

  @override
  void initState() {
    super.initState();
    final fitting = RepositoryProvider.of<FittingSimulator>(context, listen: false);
    currentShieldPercentage = fitting.currentShieldPercentage;
  }

  @override
  Widget build(BuildContext context) {

    final fitting = RepositoryProvider.of<FittingSimulator>(context);

    final shieldStr = (currentShieldPercentage * 100).toStringAsFixed(1);

    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Text('Shield Percentage $shieldStr%'),
        ),
        Expanded(
          child: SliderTheme(
            data: SliderThemeData(
              trackShape: GradientRectSliderTrackShape(
                gradient: rateGradient,
              ),
            ),
            child: Slider(
              value: currentShieldPercentage,
              onChanged: (value) {
                setState(() {
                  currentShieldPercentage = value;
                });
              },
              onChangeEnd: (value) {
                setState(() {
                  currentShieldPercentage = value;
                  fitting.updateShieldPercentage(value);
                });
              },
              min: 0.0,
              max: 1,
              divisions: 20,
            ),
          ),
        ),
      ],
    );
  }
}