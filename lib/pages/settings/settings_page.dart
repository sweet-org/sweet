import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/settings_bloc/settings_bloc.dart';
import 'widgets/settings_list.dart';

class SettingsPage extends StatelessWidget {
  static const routeName = '/settings';
  final bool closeButtonEnabled;

  const SettingsPage({super.key, this.closeButtonEnabled = false});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SettingsBloc>(
      create: (context) => SettingsBloc(),
      child: Scaffold(
        body: SettingsList(closeButtonEnabled: closeButtonEnabled),
      ),
    );
  }
}
