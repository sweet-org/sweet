import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';
import 'package:sweet/extensions/duration_extension.dart';
import 'package:sweet/model/ship/capacitor_simulation_results.dart';
import 'package:sweet/service/fitting_simulator.dart';
import 'package:sweet/repository/localisation_repository.dart';
import 'package:sweet/util/localisation_constants.dart';
import 'package:sweet/widgets/value_with_title.dart';

import 'nihilus_modifier_selector.dart';

class CapacitorUsageWidget extends StatelessWidget {
  final bool condensed;

  const CapacitorUsageWidget({
    Key? key,
    this.condensed = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var fitting = Provider.of<FittingSimulator>(context);

    return FutureBuilder<CapacitorSimulationResults>(
      future: fitting.capacitorSimulation(),
      initialData: CapacitorSimulationResults.zero,
      builder: _buildWidget,
    );
  }

  Widget _buildWidget(BuildContext context,
      AsyncSnapshot<CapacitorSimulationResults> snapshot) {
    final localisationRepository =
        RepositoryProvider.of<LocalisationRepository>(context);
    final capSimResults = snapshot.data;
    if (capSimResults == null) return Container();

    final isStable = capSimResults.ttl.inHours >= 1;

    final title = isStable
        ? localisationRepository
            .getLocalisedStringForIndex(LocalisationStrings.stable)
        : capSimResults.ttl.toMinuteAndSecondsString();

    return Column(
      children: [
        NihilusModifierSelector(),
        condensed
            ? _buildCondensed(
                title: title,
                capSimResults: capSimResults,
                localisation: localisationRepository,
              )
            : _buildFullSize(
                title: title,
                capSimResults: capSimResults,
                localisation: localisationRepository,
              ),
      ],
    );
  }

  Widget _buildCondensed({
    required String title,
    required CapacitorSimulationResults capSimResults,
    required LocalisationRepository localisation,
  }) {
    final gjPerSecUnit = localisation.getLocalisedStringForIndex(
      LocalisationStrings.gjPerSecondUnit,
    );
    final gjUnit = localisation.getLocalisedStringForIndex(
      LocalisationStrings.gjUnit,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 8.0,
        vertical: 4.0,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ValueWithTitle(
              title: 'Capacitor Recharge Rate',
              value:
                  '${capSimResults.delta.toStringAsFixed(2)} $gjPerSecUnit (${(capSimResults.deltaPercentage * 100).toStringAsFixed(2)} %)'),
          ValueWithTitle(title: 'Duration', value: title),
          ValueWithTitle(
              title: 'Capacitor Capacity',
              value: '${capSimResults.capacity.toStringAsFixed(2)} $gjUnit'),
          ValueWithTitle(
              title: 'Recharge Time',
              value: '${capSimResults.rechargeTime.inSeconds}s'),
        ],
      ),
    );
  }

  Widget _buildFullSize({
    required String title,
    required CapacitorSimulationResults capSimResults,
    required LocalisationRepository localisation,
  }) {
    var steps = 32;
    var rings = 8;
    var minSize = 48.0;
    var sizeStep = 8.0;

    final gjPerSecUnit = localisation.getLocalisedStringForIndex(
      LocalisationStrings.gjPerSecondUnit,
    );
    final gjUnit = localisation.getLocalisedStringForIndex(
      LocalisationStrings.gjUnit,
    );

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Text(title),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(
                        '${capSimResults.delta.toStringAsFixed(2)} $gjPerSecUnit'),
                    Text(
                        '${(capSimResults.deltaPercentage * 100).toStringAsFixed(2)} %'),
                  ],
                ),
              ),
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CapacitorProgressBar(
                      rings: rings,
                      steps: steps,
                      capSimResults: capSimResults,
                      minSize: minSize,
                      sizeStep: sizeStep),
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                        '${capSimResults.capacity.toStringAsFixed(2)} $gjUnit'),
                    Text('${capSimResults.rechargeTime.inSeconds}s')
                  ],
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class CapacitorProgressBar extends StatelessWidget {
  const CapacitorProgressBar({
    Key? key,
    required this.rings,
    required this.steps,
    required this.capSimResults,
    required this.minSize,
    required this.sizeStep,
  }) : super(key: key);

  final int rings;
  final int steps;
  final CapacitorSimulationResults capSimResults;
  final double minSize;
  final double sizeStep;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        for (int i = 0; i < rings; i++)
          CircularStepProgressIndicator(
            selectedColor: Theme.of(context).colorScheme.secondary,
            unselectedColor:
                Theme.of(context).colorScheme.secondary.withAlpha(32),
            totalSteps: steps,
            currentStep: (steps * capSimResults.loadBalance).toInt(),
            stepSize: sizeStep / 4,
            padding: math.pi /
                ((i * (minSize / sizeStep)) + (minSize / 2 + sizeStep)),
            circularDirection: CircularDirection.counterclockwise,
            width: (i * sizeStep) + minSize,
            height: (i * sizeStep) + minSize,
            // roundedCap: (index, _) => true,
          )
      ],
    );
  }
}
