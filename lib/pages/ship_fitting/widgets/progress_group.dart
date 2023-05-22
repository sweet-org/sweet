import 'package:flutter/material.dart';
import 'package:sweet/model/ship/eve_echoes_attribute.dart';
import 'package:sweet/pages/ship_fitting/widgets/attribute_progress_bar.dart';

class ProgressBarGroup extends StatelessWidget {
  final List<EveEchoesAttribute> attributes;
  final Widget? icon;

  const ProgressBarGroup({
    Key? key,
    required this.attributes,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon ??
                  Container(
                    height: Theme.of(context).iconTheme.size,
                  ),
            ],
          ),
        ),
        ...attributes.map(
          (e) => AttributeProgressBar(
            attribute: e,
            attributeValue: 0.5,
          ),
        ),
      ],
    );
  }
}
