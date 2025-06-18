import 'package:provider/provider.dart';
import 'package:sweet/extensions/duration_extension.dart';
import 'package:sweet/model/ship/capacitor_simulation_results.dart';
import 'package:sweet/service/fitting_simulator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sweet/repository/localisation_repository.dart';
import 'package:sweet/util/localisation_constants.dart';

import 'ship_fitting_toolbar_button.dart';

class ShipFittingCapacitorToolbarButton extends StatelessWidget {
  final IconData icon;
  final GestureTapCallback onTap;

  const ShipFittingCapacitorToolbarButton({
    super.key,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    var fitting = Provider.of<FittingSimulator>(context);
    var localisationRepository =
        RepositoryProvider.of<LocalisationRepository>(context);
    return FutureBuilder<CapacitorSimulationResults>(
        future: fitting.capacitorSimulation(),
        builder: (context, snapshot) {
          var capSimResults = snapshot.data;
          if (capSimResults == null) {
            return Container();
          }

          final isStable = capSimResults.ttl.inHours >= 1;

          final title = isStable
              ? localisationRepository
                  .getLocalisedStringForIndex(LocalisationStrings.stable)
              : capSimResults.ttl.toMinuteAndSecondsString();

          return ShipFittingToolbarButton(
            icon: icon,
            title: title,
            onTap: onTap,
          );
        });
  }
}
