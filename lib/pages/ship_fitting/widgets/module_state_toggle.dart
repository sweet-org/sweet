import 'package:flutter/material.dart';
import 'package:sweet/model/ship/module_state.dart';

typedef ModuleStateToggleCallback = void Function(ModuleState state);

class ModuleStateToggle extends StatefulWidget {
  final ModuleStateToggleCallback onToggle;
  final ModuleState state;

  const ModuleStateToggle({
    super.key,
    required this.onToggle,
    required this.state,
  });

  @override
  State<ModuleStateToggle> createState() => _ModuleStateToggleState();
}

class _ModuleStateToggleState extends State<ModuleStateToggle> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () => setState(() {
        // NOTE: When Overloading is a thing ;)
        // var newState = widget.state == ModuleState.overload
        //     ? ModuleState.active
        //     : ModuleState.overload;
        // widget.onToggle(newState);
      }),
      onTap: () => setState(() {
        var newState = widget.state == ModuleState.active
            ? ModuleState.inactive
            : ModuleState.active;
        widget.onToggle(newState);
      }),
      child: Icon(_iconForState(widget.state)),
    );
  }

  IconData _iconForState(ModuleState state) {
    switch (state) {
      case ModuleState.inactive:
        return Icons.radio_button_off;
      case ModuleState.active:
        return Icons.power_settings_new_rounded;
      case ModuleState.overload:
        return Icons.local_fire_department;
    }
  }
}
