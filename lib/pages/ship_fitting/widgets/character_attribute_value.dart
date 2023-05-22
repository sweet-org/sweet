import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sweet/model/ship/eve_echoes_attribute.dart';
import 'package:sweet/service/fitting_simulator.dart';
import 'package:sweet/widgets/item_attribute_value_widget.dart';

class CharacterAttributeValue extends StatelessWidget {
  final EveEchoesAttribute attribute;
  final String? titleOverride;
  final int? titleIdOverride;
  final String? unitOverride;
  final bool useSpacer;
  final double Function(double)? formulaOverride;
  final TextStyle? style;

  const CharacterAttributeValue({
    Key? key,
    required this.attribute,
    this.titleOverride,
    this.titleIdOverride,
    this.unitOverride,
    this.formulaOverride,
    this.useSpacer = true,
    this.style,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(4),
      child: Consumer<FittingSimulator>(
        builder: (context, fitting, widget) => ItemAttributeValueWidget(
          showAttributeId: false,
          fixedDecimals: 2,
          formulaOverride: formulaOverride,
          titleOverride: titleOverride,
          titleIdOverride: titleIdOverride,
          unitOverride: unitOverride,
          attributeId: attribute.attributeId,
          attributeValue: fitting.getValueForCharacter(attribute: attribute),
          useSpacer: useSpacer,
          style: style,
        ),
      ),
    );
  }
}
