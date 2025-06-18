import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:sweet/service/fitting_simulator.dart';
import 'package:sweet/util/constants.dart';
import 'package:sweet/util/localisation_constants.dart';

class EffectiveHP extends StatelessWidget {
  const EffectiveHP({
    super.key,
    this.condense = true,
  });

  final bool condense;

  @override
  Widget build(BuildContext context) {
    final fitting = RepositoryProvider.of<FittingSimulator>(context);
    final weakestEHPString = NumberFormat(StringFormats.twoDecimalPlaces)
        .format(fitting.calculateWeakestEHP());

    return condense
        ? Text(
            '${StaticLocalisationStrings.effectiveHP}: $weakestEHPString',
            style: Theme.of(context).textTheme.bodySmall,
          )
        : Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                // TODO: Add tooltip to indicate this is based on Weakest
                Text(StaticLocalisationStrings.effectiveHP),
                Expanded(
                  child: Text(
                    weakestEHPString,
                    textAlign: TextAlign.right,
                  ),
                )
              ],
            ),
          );
  }
}
