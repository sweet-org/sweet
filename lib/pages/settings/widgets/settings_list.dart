import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sweet/service/settings_service.dart';
import 'package:sweet/util/localisation_constants.dart';

import '../bloc/settings_bloc/settings_bloc.dart';
import 'text_setting_widget.dart';
import 'toggle_setting_widget.dart';

class SettingsList extends StatefulWidget {
  final bool closeButtonEnabled;
  const SettingsList({super.key, this.closeButtonEnabled = false});

  @override
  State<SettingsList> createState() => _SettingsListState();
}

class _SettingsListState extends State<SettingsList> {
  @override
  void initState() {
    super.initState();
    // Load settings when widget initializes
    context.read<SettingsBloc>().add(LoadSettingsEvent());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        final darkTheme = AdaptiveTheme.of(context);

        final currentMode = darkTheme.mode == AdaptiveThemeMode.system
            ? 'System'
            : darkTheme.mode == AdaptiveThemeMode.dark
            ? 'Dark'
            : 'Light';

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Server Settings',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextSettingWidget(
              label: 'Primary Server Address',
              value: state.primaryServerAddress,
              defaultValue: SettingsService.kDefaultPrimaryServer,
              isCustomized: state.isPrimaryServerCustomized,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Server address cannot be empty';
                }
                return null;
              },
              onSaved: (value) {
                context
                    .read<SettingsBloc>()
                    .add(UpdatePrimaryServerEvent(value));
              },
            ),
            const SizedBox(height: 16),
            TextSettingWidget(
              label: 'Fallback Server Address',
              value: state.fallbackServerAddress,
              defaultValue: SettingsService.kDefaultFallbackServer,
              isCustomized: state.isFallbackServerCustomized,
              enabled: state.fallbackServerEnabled,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Server address cannot be empty';
                }
                return null;
              },
              onSaved: (value) {
                context
                    .read<SettingsBloc>()
                    .add(UpdateFallbackServerEvent(value));
              },
            ),
            const SizedBox(height: 8),
            ToggleSettingWidget(
              label: 'Enable Fallback Server',
              value: state.fallbackServerEnabled,
              onChanged: (value) {
                context
                    .read<SettingsBloc>()
                    .add(ToggleFallbackServerEvent(value));
              },
            ),
            ListTile(
              leading: Icon(
                Icons.nightlight_round,
                size: 24,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              title: Text(StaticLocalisationStrings.theme),
              subtitle: Text(currentMode),
              onTap: () {
                darkTheme.toggleThemeMode();
              },
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                widget.closeButtonEnabled ? ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Close'),
                ) : null,
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                  onPressed: () {
                    context.read<SettingsBloc>().add(ResetSettingsEvent());
                  },
                  child: Text('Reset to Defaults'),
                ),
              ].nonNulls.toList(growable: false),
            ),
          ],
        );
      },
    );
  }
}
