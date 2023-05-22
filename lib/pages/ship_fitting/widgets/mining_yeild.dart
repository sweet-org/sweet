import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sweet/repository/localisation_repository.dart';
import 'package:sweet/service/fitting_simulator.dart';
import 'package:sweet/extensions/duration_extension.dart';
import 'package:sweet/util/localisation_constants.dart';

enum YeildTypes { turret, drones, timeToFill }

class MiningYeild extends StatelessWidget {
  final YeildTypes type;

  MiningYeild({
    required this.type,
  });

  String get _iconName {
    switch (type) {
      case YeildTypes.turret:
        return 'assets/icons/mining-laser.png';
      case YeildTypes.drones:
        return 'assets/icons/icon-drones.png';
      case YeildTypes.timeToFill:
        return 'assets/icons/container-large.png';
    }
  }

  String _totalString({
    required FittingSimulator fitting,
  }) {
    switch (type) {
      case YeildTypes.turret:
        return NumberFormat('#,##0.00')
            .format(fitting.calculateTotalMiningYeild());
      case YeildTypes.drones:
        return NumberFormat('#,##0.00')
            .format(fitting.calculateTotalMiningYeildForDrones());
      case YeildTypes.timeToFill:
        return 'Time to fill'; // TODO: Localise
    }
  }

  String _timeString({
    required FittingSimulator fitting,
    required LocalisationRepository localisation,
  }) {
    final perMinString = localisation.getLocalisedStringForIndex(
      LocalisationStrings.perMinUnit,
    );
    switch (type) {
      case YeildTypes.turret:
        final ypm = fitting.calculateTotalMiningYeildPerMinute();
        return '${NumberFormat('#,##0.00').format(ypm)}$perMinString'; // TODO: Localise
      case YeildTypes.drones:
        final ypm = fitting.calculateTotalMiningYeildPerMinuteForDrones();
        return '${NumberFormat('#,##0.00').format(ypm)}$perMinString';
      case YeildTypes.timeToFill:
        final timeToFill = fitting.calculateMiningTimeToFill();
        return timeToFill.toTimeString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final localisation = RepositoryProvider.of<LocalisationRepository>(context);
    return Container(
      margin: EdgeInsets.all(2),
      child: Column(
        children: [
          Image.asset(
            _iconName,
            height: 64,
          ),
          Padding(
            padding: EdgeInsets.all(2),
            child: Consumer<FittingSimulator>(
              builder: (context, fitting, widget) => Column(
                children: [
                  Text(_timeString(
                    fitting: fitting,
                    localisation: localisation,
                  )),
                  Text(_totalString(fitting: fitting)),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
