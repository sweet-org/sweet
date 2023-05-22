

import 'package:flutter/material.dart';
import 'package:sweet/model/fitting/fitting_patterns.dart';
import 'damage_pattern_header.dart';
import 'damage_pattern_row.dart';

class DamagePatternWidget extends StatelessWidget {
  final double rowHeight;
  final FittingPattern damagePattern;
  final VoidCallback onChangeDamagePattern;

  const DamagePatternWidget({
    Key? key,
    required this.rowHeight,
    required this.damagePattern,
    required this.onChangeDamagePattern,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onChangeDamagePattern,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DamagePatternHeader(rowHeight: rowHeight),
          DamagePatternRow(
            rowHeight: rowHeight,
            rowIcon: Image.asset(
              'assets/icons/damage_pattern.png',
              height: rowHeight,
            ),
            damagePattern: damagePattern,
          ),
        ],
      ),
    );
  }
}
