import 'package:flutter/material.dart';

import 'package:sweet/model/fitting/fitting_module.dart';
import 'package:sweet/model/ship/module_state.dart';
import 'package:sweet/widgets/localised_text.dart';

class ShipModeToggle extends StatelessWidget {
  const ShipModeToggle({
    super.key,
    required this.shipMode,
    required this.onInfoTapped,
    required this.onChanged,
  });

  final FittingModule? shipMode;
  final void Function(bool enabled) onChanged;
  final VoidCallback onInfoTapped;

  @override
  Widget build(BuildContext context) {
    final mode = shipMode;

    if (mode == null) return Container();

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        IconButton(
          padding: EdgeInsets.only(right: 4),
          constraints: BoxConstraints.tight(Size.square(32)),
          icon: Icon(
            Icons.info,
          ),
          onPressed: onInfoTapped,
        ),
        LocalisedText(item: mode.item),
        Switch(
          value: shipMode!.state == ModuleState.active,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
