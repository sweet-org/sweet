import 'package:flutter/material.dart';
import 'package:sweet/pages/ship_fitting/widgets/bordered_text.dart';
import 'package:tinycolor2/tinycolor2.dart';

class IconProgressbar extends StatelessWidget {
  final double value;
  final Color color;
  final Widget? icon;
  final String label;
  final double height;
  final double borderWidth;

  const IconProgressbar({
    super.key,
    required this.value,
    required this.color,
    this.icon,
    required this.label,
    this.height = 24,
    this.borderWidth = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: borderWidth,
                      color: Colors.black,
                    ),
                  ),
                  child: LinearProgressIndicator(
                    value: value,
                    minHeight: height - borderWidth,
                    backgroundColor: color.darken(30),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    icon != null
                        ? Padding(
                            padding: EdgeInsets.only(right: 8),
                            child: icon,
                          )
                        : Container(),
                    BorderedText(
                      label,
                      borderColor: Colors.black.withAlpha(64),
                      borderWidth: 3,
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
