import 'package:provider/provider.dart';
import 'package:sweet/model/ship/eve_echoes_attribute.dart';
import 'package:sweet/service/fitting_simulator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:sweet/repository/localisation_repository.dart';
import 'package:sweet/util/localisation_constants.dart';

import 'ship_fitting_toolbar_button.dart';

class ShipFittingDroneRangeToolbarButton extends StatelessWidget {
  final IconData icon;
  final GestureTapCallback onTap;

  const ShipFittingDroneRangeToolbarButton({
    Key? key,
    required this.icon,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var fitting = Provider.of<FittingSimulator>(context);
    var localisationRepository =
        RepositoryProvider.of<LocalisationRepository>(context);

    var unitString = localisationRepository.getLocalisedStringForIndex(
      LocalisationStrings.kmUnit,
    );
    var rangeInMeters = fitting.getValueForCharacter(
      attribute: EveEchoesAttribute.droneControlRange,
    );

    var title = '${NumberFormat().format(rangeInMeters / 1000)} $unitString';

    return ShipFittingToolbarButton(
      icon: icon,
      title: title,
      onTap: onTap,
    );
  }
}
