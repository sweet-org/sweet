

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:sweet/model/ship/eve_echoes_attribute.dart';

class ResistanceRowHeader extends StatelessWidget {
  const ResistanceRowHeader({
    super.key,
    required this.rowHeight,
    required this.showEHP,
    required this.onEHPToggle,
  });

  final double rowHeight;
  final bool showEHP;
  final VoidCallback onEHPToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: 2),
            child: Container(
              height: rowHeight,
              width: rowHeight,
            ),
          ),
          Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 2),
              height: rowHeight,
              child: Image.asset(
                EveEchoesAttribute.shieldEmDamageResonance.iconName!,
              ),
            ),
          ),
          Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 2),
              height: rowHeight,
              child: Image.asset(
                EveEchoesAttribute.shieldThermalDamageResonance.iconName!,
              ),
            ),
          ),
          Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 2),
              height: rowHeight,
              child: Image.asset(
                EveEchoesAttribute.shieldKineticDamageResonance.iconName!,
              ),
            ),
          ),
          Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 2),
              height: rowHeight,
              child: Image.asset(
                EveEchoesAttribute.shieldExplosiveDamageResonance.iconName!,
              ),
            ),
          ),
          Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 2),
              alignment: Alignment.center,
              height: rowHeight,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
                ),
                onPressed: onEHPToggle,
                child: AutoSizeText(
                  showEHP ? 'EHP' : 'Raw',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
