import 'package:flutter/material.dart';
import 'package:sweet/model/fitting/fitting_patterns.dart';
import 'package:sweet/model/ship/eve_echoes_attribute.dart';

import '../attribute_progress_bar.dart';

class DamagePatternRow extends StatelessWidget {
  const DamagePatternRow({
    super.key,
    required this.rowHeight,
    required this.damagePattern,
    this.rowIcon,
    this.leading,
    this.trailing,
  });

  final Widget? leading;
  final Widget? rowIcon;
  final Widget? trailing;
  final FittingPattern damagePattern;
  final double rowHeight;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: 2),
            child: rowIcon ?? Container(),
          ),
          leading != null
              ? Expanded(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 2),
                    alignment: Alignment.centerLeft,
                    height: rowHeight,
                    child: leading,
                  ),
                )
              : Container(),
          Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 2),
              height: rowHeight,
              child: AttributeProgressBar(
                height: rowHeight,
                formulaOverride: (value) => value * 100,
                unitOverride: '%',
                attribute: EveEchoesAttribute.emDamage,
                attributeValue: damagePattern.emPercent,
              ),
            ),
          ),
          Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 2),
              height: rowHeight,
              child: AttributeProgressBar(
                height: rowHeight,
                formulaOverride: (value) => value * 100,
                unitOverride: '%',
                attribute: EveEchoesAttribute.thermalDamage,
                attributeValue: damagePattern.thermalPercent,
              ),
            ),
          ),
          Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 2),
              height: rowHeight,
              child: AttributeProgressBar(
                height: rowHeight,
                formulaOverride: (value) => value * 100,
                unitOverride: '%',
                attribute: EveEchoesAttribute.kineticDamage,
                attributeValue: damagePattern.kineticPercent,
              ),
            ),
          ),
          Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 2),
              height: rowHeight,
              child: AttributeProgressBar(
                height: rowHeight,
                formulaOverride: (value) => value * 100,
                unitOverride: '%',
                attribute: EveEchoesAttribute.explosiveDamage,
                attributeValue: damagePattern.explosivePercent,
              ),
            ),
          ),
          trailing != null
              ? Expanded(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 2),
                    alignment: Alignment.center,
                    height: rowHeight,
                    child: trailing,
                  ),
                )
              : Container(),
        ],
      ),
    );
  }
}
