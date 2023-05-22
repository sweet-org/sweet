import 'package:flutter/material.dart';
import 'package:sweet/pages/ship_fitting/widgets/capacitor_progress_bar.dart';
import 'package:sweet/pages/ship_fitting/widgets/offense_widgets/firepower_breakdown.dart';
import 'package:sweet/pages/ship_fitting/widgets/power_usage_bar.dart';
import 'package:sweet/pages/ship_fitting/widgets/toolbar_buttons/ship_fitting_max_velocity_button.dart';

import 'defence_widgets/ship_fitting_defence_widget.dart';
import 'ship_fitting_navigation_details.dart';
import 'toolbar_buttons/ship_fitting_dps_toolbar_button.dart';
import 'toolbar_buttons/ship_fitting_ehp_toolbar_button.dart';
import 'toolbar_buttons/ship_fitting_capacitor_toolbar_button.dart';

enum FittingStats {
  none,
  powerGrid,
  defense,
  offense,
  capacitor,
  navigation,
  targeting,
  allAttributes
}

class ShipFittingToolbar extends StatefulWidget {
  const ShipFittingToolbar({
    Key? key,
  }) : super(key: key);

  @override
  State<ShipFittingToolbar> createState() => _ShipFittingToolbarState();
}

class _ShipFittingToolbarState extends State<ShipFittingToolbar>
    with TickerProviderStateMixin {
  FittingStats? selectedStat;

  void onButtonTapped(FittingStats statsToShow) {
    setState(() {
      if (statsToShow == selectedStat) {
        selectedStat = FittingStats.none;
      } else {
        selectedStat = statsToShow;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 35.0,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 8.0,
        ),
        child: SafeArea(
          top: false,
          bottom: true,
          child: AnimatedSize(
            curve: Curves.fastOutSlowIn,
            alignment: Alignment.bottomCenter,
            duration: Duration(milliseconds: 250),
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.only(left: 4, right: 4, bottom: 8.0),
                  child: selectedStat != null
                      ? _buildPanelForStat(selectedStat!, context)
                      : Container(),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: _buildButtonsRow(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Row _buildButtonsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ShipFittingDPSToolbarButton(
          icon: Icons.camera,
          onTap: () => onButtonTapped(FittingStats.offense),
        ),
        ShipFittingEHPToolbarButton(
          icon: Icons.local_library,
          onTap: () => onButtonTapped(FittingStats.defense),
        ),
        ShipFittingCapacitorToolbarButton(
          icon: Icons.battery_charging_full,
          onTap: () => onButtonTapped(FittingStats.capacitor),
        ),
        ShipFittingMaxVelocityToolbarButton(
          icon: Icons.speed,
          onTap: () => onButtonTapped(FittingStats.navigation),
        ),
      ],
    );
  }

  Widget _buildPanelForStat(FittingStats selectedStat, BuildContext context) {
    switch (selectedStat) {
      case FittingStats.allAttributes:
      case FittingStats.none:
        return Container();

      case FittingStats.powerGrid:
        return PowerUsageBar();
      case FittingStats.defense:
        return ShipFittingDefenceWidget();

      case FittingStats.offense:
        return Column(
          children: [
            FirepowerBreakdown(),
          ],
        );
      case FittingStats.capacitor:
        return CapacitorUsageWidget();
      case FittingStats.navigation:
        return ShipFittingNavigationDetails();
      case FittingStats.targeting:
        return Container();
    }
  }
}
