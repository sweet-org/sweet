import 'package:flutter/material.dart';

import 'package:sweet/pages/ship_fitting/widgets/ship_fitting_navigation_details.dart';
import 'package:sweet/util/localisation_constants.dart';
import 'package:sweet/widgets/localised_text.dart';

import 'capacitor_progress_bar.dart';
import 'defence_widgets/effective_hp.dart';
import 'defence_widgets/ship_fitting_defence_widget.dart';
import 'offense_widgets/firepower_breakdown.dart';

class ShipFittingDetailPanel extends StatelessWidget {
  final _scrollController = ScrollController();

  ShipFittingDetailPanel({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: _scrollController,
      children: [
        ExpansionTile(
          title: Text(StaticLocalisationStrings.firepower),
          initiallyExpanded: true,
          children: [FirepowerBreakdown(condensed: true)],
        ),
        ExpansionTile(
          title: LocalisedText(localiseId: LocalisationStrings.resistanceInfo),
          subtitle: EffectiveHP(),
          initiallyExpanded: true,
          children: [ShipFittingDefenceWidget(condensed: true)],
        ),
        ExpansionTile(
          title: LocalisedText(localiseId: LocalisationStrings.capacitor),
          initiallyExpanded: true,
          children: [CapacitorUsageWidget(condensed: true)],
        ),
        ExpansionTile(
          title: Text(StaticLocalisationStrings.misc),
          initiallyExpanded: true,
          children: [ShipFittingNavigationDetails(condensed: true)],
        ),
      ],
    );
  }
}
