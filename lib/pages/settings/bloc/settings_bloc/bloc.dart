// lib/pages/settings/bloc/settings_bloc/bloc.dart
import 'package:bloc/bloc.dart';
import 'package:sweet/service/settings_service.dart';

import 'events.dart';
import 'state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsService _settingsService = SettingsService();

  SettingsBloc()
      : super(const SettingsState(
          primaryServerAddress: SettingsService.kDefaultPrimaryServer,
          fallbackServerAddress: SettingsService.kDefaultFallbackServer,
          fallbackServerEnabled: SettingsService.kDefaultFallbackEnabled,
          isPrimaryServerCustomized: false,
          isFallbackServerCustomized: false,
          isFallbackEnabledCustomized: false,
        )) {
    on<LoadSettingsEvent>(_onLoadSettings);
    on<UpdatePrimaryServerEvent>(_onUpdatePrimaryServer);
    on<UpdateFallbackServerEvent>(_onUpdateFallbackServer);
    on<ToggleFallbackServerEvent>(_onToggleFallbackServer);
    on<ResetSettingsEvent>(_onResetSettings);
  }

  Future<void> _onLoadSettings(
      LoadSettingsEvent event, Emitter<SettingsState> emit) async {
    final primaryServer = await _settingsService.getPrimaryServer();
    final fallbackServer = await _settingsService.getFallbackServer();
    final fallbackEnabled = await _settingsService.getFallbackEnabled();

    final isPrimaryCustomized = await _settingsService
        .isCustomized(SettingsService.kKeyChangedPrimaryServer);
    final isFallbackCustomized = await _settingsService
        .isCustomized(SettingsService.kKeyChangedFallbackServer);
    final isFallbackEnabledCustomized = await _settingsService
        .isCustomized(SettingsService.kKeyChangedFallbackEnabled);

    emit(SettingsState(
      primaryServerAddress: primaryServer,
      fallbackServerAddress: fallbackServer,
      fallbackServerEnabled: fallbackEnabled,
      isPrimaryServerCustomized: isPrimaryCustomized,
      isFallbackServerCustomized: isFallbackCustomized,
      isFallbackEnabledCustomized: isFallbackEnabledCustomized,
    ));
  }

  Future<void> _onUpdatePrimaryServer(
      UpdatePrimaryServerEvent event, Emitter<SettingsState> emit) async {
    await _settingsService.setPrimaryServer(event.address);

    emit(state.copyWith(
      primaryServerAddress: event.address,
      isPrimaryServerCustomized:
          event.address != SettingsService.kDefaultPrimaryServer,
    ));
  }

  Future<void> _onUpdateFallbackServer(
      UpdateFallbackServerEvent event, Emitter<SettingsState> emit) async {
    await _settingsService.setFallbackServer(event.address);

    emit(state.copyWith(
      fallbackServerAddress: event.address,
      isFallbackServerCustomized:
          event.address != SettingsService.kDefaultFallbackServer,
    ));
  }

  Future<void> _onToggleFallbackServer(
      ToggleFallbackServerEvent event, Emitter<SettingsState> emit) async {
    await _settingsService.setFallbackEnabled(event.enabled);

    emit(state.copyWith(
      fallbackServerEnabled: event.enabled,
      isFallbackEnabledCustomized:
          event.enabled != SettingsService.kDefaultFallbackEnabled,
    ));
  }

  Future<void> _onResetSettings(
      ResetSettingsEvent event, Emitter<SettingsState> emit) async {
    await _settingsService.resetAllSettings();

    emit(const SettingsState(
      primaryServerAddress: SettingsService.kDefaultPrimaryServer,
      fallbackServerAddress: SettingsService.kDefaultFallbackServer,
      fallbackServerEnabled: SettingsService.kDefaultFallbackEnabled,
      isPrimaryServerCustomized: false,
      isFallbackServerCustomized: false,
      isFallbackEnabledCustomized: false,
    ));
  }
}
