import 'package:flutter/material.dart';

class ShipFittingToolbarButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final GestureTapCallback onTap;

  const ShipFittingToolbarButton(
      {Key? key, required this.icon, required this.title, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Icon(icon),
          ),
          Text(
            title,
            style: TextStyle(
              color:
                  Theme.of(context).textTheme.bodyLarge!.color!.withAlpha(128),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
