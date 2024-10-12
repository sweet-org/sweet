import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sweet/pages/ship_fitting/widgets/defence_widgets/shield_selector.dart';
import 'package:sweet/pages/ship_fitting/widgets/defence_widgets/recharge_rates.dart';

import '../../../../service/fitting_simulator.dart';
import '../../bloc/ship_fitting_bloc/ship_fitting.dart';

import '../offense_widgets/damage_pattern_widget.dart';
import 'defence_resistances.dart';
import 'implant_defense_bonus.dart';

class ShipFittingDefenceWidget extends StatefulWidget {
  final bool condensed;

  const ShipFittingDefenceWidget({
    Key? key,
    this.rowHeight = 28,
    this.condensed = false,
  }) : super(key: key);

  final double rowHeight;

  @override
  State<ShipFittingDefenceWidget> createState() =>
      _ShipFittingDefenceWidgetState();
}

class _ShipFittingDefenceWidgetState extends State<ShipFittingDefenceWidget> {
  bool _showEHP = false;

  @override
  Widget build(BuildContext context) {
    final fitting = RepositoryProvider.of<FittingSimulator>(context);
    final damagePattern = fitting.currentDamagePattern;

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: ShieldSelectSlider(),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: ImplantDefenseBonusWidget(),
        ),
        DefenceResistances(
          rowHeight: widget.rowHeight,
          damagePattern: damagePattern,
          onEhpToggle: (show) => setState(() {
            _showEHP = show;
          }),
        ),
        Container(
          margin: EdgeInsets.all(6),
          height: 1,
          color: Colors.black.withAlpha(64),
        ),
        RechargeRates(
          showEhp: _showEHP,
          damagePattern: damagePattern,
        ),
        Container(
          margin: EdgeInsets.all(6),
          height: 1,
          color: Colors.black.withAlpha(64),
        ),
        DamagePatternWidget(
          rowHeight: widget.rowHeight,
          damagePattern: damagePattern,
          onChangeDamagePattern: () => context.read<ShipFittingBloc>().add(
                ChangeDamagePatternForFitting(),
              ),
        ),
      ],
    );
  }
}
