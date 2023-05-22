

import 'package:flutter/material.dart';
import 'package:sweet/model/ship/eve_echoes_attribute.dart';

class DamagePatternHeader extends StatelessWidget {
  const DamagePatternHeader({
    Key? key,
    required this.rowHeight,
    this.trailing,
  }) : super(key: key);

  final double rowHeight;
  final Widget? trailing;

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
                EveEchoesAttribute.emDamage.iconName!,
              ),
            ),
          ),
          Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 2),
              height: rowHeight,
              child: Image.asset(
                EveEchoesAttribute.thermalDamage.iconName!,
              ),
            ),
          ),
          Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 2),
              height: rowHeight,
              child: Image.asset(
                EveEchoesAttribute.kineticDamage.iconName!,
              ),
            ),
          ),
          Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 2),
              height: rowHeight,
              child: Image.asset(
                EveEchoesAttribute.explosiveDamage.iconName!,
              ),
            ),
          ),
          trailing != null ? Expanded(child: trailing!) : Container(),
        ],
      ),
    );
  }
}
