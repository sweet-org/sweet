import 'package:equatable/equatable.dart';

class SettingsState extends Equatable {
  final String primaryServerAddress;
  final String fallbackServerAddress;
  final bool fallbackServerEnabled;
  final bool isPrimaryServerCustomized;
  final bool isFallbackServerCustomized;
  final bool isFallbackEnabledCustomized;

  const SettingsState({
    required this.primaryServerAddress,
    required this.fallbackServerAddress,
    required this.fallbackServerEnabled,
    required this.isPrimaryServerCustomized,
    required this.isFallbackServerCustomized,
    required this.isFallbackEnabledCustomized,
  });

  SettingsState copyWith({
    String? primaryServerAddress,
    String? fallbackServerAddress,
    bool? fallbackServerEnabled,
    bool? isPrimaryServerCustomized,
    bool? isFallbackServerCustomized,
    bool? isFallbackEnabledCustomized,
  }) {
    return SettingsState(
      primaryServerAddress: primaryServerAddress ?? this.primaryServerAddress,
      fallbackServerAddress:
          fallbackServerAddress ?? this.fallbackServerAddress,
      fallbackServerEnabled:
          fallbackServerEnabled ?? this.fallbackServerEnabled,
      isPrimaryServerCustomized:
          isPrimaryServerCustomized ?? this.isPrimaryServerCustomized,
      isFallbackServerCustomized:
          isFallbackServerCustomized ?? this.isFallbackServerCustomized,
      isFallbackEnabledCustomized:
          isFallbackEnabledCustomized ?? this.isFallbackEnabledCustomized,
    );
  }

  @override
  List<Object?> get props => [
        primaryServerAddress,
        fallbackServerAddress,
        fallbackServerEnabled,
        isPrimaryServerCustomized,
        isFallbackServerCustomized,
        isFallbackEnabledCustomized,
      ];
}
