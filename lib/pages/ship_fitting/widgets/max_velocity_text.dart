import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sweet/service/fitting_simulator.dart';
import 'package:sweet/util/localisation_constants.dart';
import 'package:sweet/widgets/localised_text.dart';

class MaxVelocityText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(4),
      child: Consumer<FittingSimulator>(
        builder: (context, fitting, widget) => Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 4.0),
                child: LocalisedText(
                  localiseId: LocalisationStrings.maxVelocity,
                ),
              ),
            ),
            AutoSizeText(
                '${NumberFormat('#,##0.00').format(fitting.maxFlightVelocity())} m/s'),
          ],
        ),
      ),
    );
  }
}
