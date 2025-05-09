import 'package:equatable/equatable.dart';

abstract class SettingsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadSettingsEvent extends SettingsEvent {}

class UpdatePrimaryServerEvent extends SettingsEvent {
  final String address;

  UpdatePrimaryServerEvent(this.address);

  @override
  List<Object?> get props => [address];
}

class UpdateFallbackServerEvent extends SettingsEvent {
  final String address;

  UpdateFallbackServerEvent(this.address);

  @override
  List<Object?> get props => [address];
}

class ToggleFallbackServerEvent extends SettingsEvent {
  final bool enabled;

  ToggleFallbackServerEvent(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

class ResetSettingsEvent extends SettingsEvent {}
