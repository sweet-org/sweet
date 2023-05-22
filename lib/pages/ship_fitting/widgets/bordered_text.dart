import 'package:flutter/material.dart';

class BorderedText extends StatelessWidget {
  final String text;
  final Color borderColor;
  final double borderWidth;
  final TextStyle? style;

  const BorderedText(
    this.text, {
    Key? key,
    required this.borderColor,
    required this.borderWidth,
    this.style,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var style = this.style ?? Theme.of(context).textTheme.bodyLarge!;
    return Stack(
      alignment: Alignment.center,
      children: [
        Text(
          text,
          style: style.copyWith(
              foreground: Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = borderWidth
                ..color = Colors.black.withAlpha(128)),
        ),
        Text(
          text,
          style: style,
        )
      ],
    );
  }
}
