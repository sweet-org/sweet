import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sweet/service/settings_service.dart';

import '../bloc/settings_bloc/settings_bloc.dart';
import 'text_setting_widget.dart';
import 'toggle_setting_widget.dart';

class SettingsList extends StatefulWidget {
  const SettingsList({super.key});

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
            const SizedBox(height: 32),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Theme.of(context).textTheme.bodySmall?.color,
                ),
                onPressed: () {
                  context.read<SettingsBloc>().add(ResetSettingsEvent());
                },
                child: Text('Reset to Defaults'),
              ),
            ),
          ],
        );
      },
    );
  }
}
