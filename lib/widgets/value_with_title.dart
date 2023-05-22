

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class ValueWithTitle extends StatelessWidget {
  final String title;
  final String value;
  final bool useSpacer;

  const ValueWithTitle({
    Key? key,
    required this.title,
    required this.value,
    this.useSpacer = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Row(
        children: [
          title.isNotEmpty ? AutoSizeText(title) : Container(),
          useSpacer ? Spacer() : Container(),
          AutoSizeText(value),
        ],
      );
}
