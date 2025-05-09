import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  // Default values
  static const String kDefaultPrimaryServer = "https://sweet.meise.blue";
  static const String kDefaultFallbackServer = "https://sweet.silkypants.dev";
  static const bool kDefaultFallbackEnabled = true;

  // Keys for SharedPreferences
  static const String kKeyPrimaryServer = "primary_server_address";
  static const String kKeyFallbackServer = "fallback_server_address";
  static const String kKeyFallbackEnabled = "fallback_server_enabled";
  static const String kKeyChangedPrimaryServer = "primary_server_changed";
  static const String kKeyChangedFallbackServer = "fallback_server_changed";
  static const String kKeyChangedFallbackEnabled = "fallback_enabled_changed";

  // Cached values
  final Map<String, dynamic> _cachedValues = {};

  // Singleton pattern
  static final SettingsService _instance = SettingsService._internal();

  factory SettingsService() => _instance;

  SettingsService._internal();

  // Generic method to get a setting with a default value
  Future<T> getSetting<T>(String key, T defaultValue, String customizedKey,
      {SharedPreferences? prefs}) async {
    // Check if the value is already cached
    if (_cachedValues.containsKey(key)) {
      return _cachedValues[key] as T;
    }
    final T value =
        await _getSetting(key, defaultValue, customizedKey, prefs: prefs);
    _cachedValues[key] = value;
    return value;
  }

  Future<T> _getSetting<T>(
    String key,
    T defaultValue,
    String customizedKey, {
    SharedPreferences? prefs,
  }) async {
    final pref = prefs ?? await SharedPreferences.getInstance();
    final isCustomized = pref.getBool(customizedKey) ?? false;
    if (!isCustomized) {
      return defaultValue;
    }
    if (T == String) {
      return (pref.getString(key) ?? defaultValue) as T;
    } else if (T == bool) {
      return (pref.getBool(key) ?? defaultValue) as T;
    } else if (T == int) {
      return (pref.getInt(key) ?? defaultValue) as T;
    } else if (T == double) {
      return (pref.getDouble(key) ?? defaultValue) as T;
    }
    return defaultValue;
  }

  // Generic method to set a setting and track customization
  Future<void> setSetting<T>(
      String key, T value, T defaultValue, String customizedKey) async {
    final prefs = await SharedPreferences.getInstance();

    // Save the value
    if (T == String) {
      await prefs.setString(key, value as String);
    } else if (T == bool) {
      await prefs.setBool(key, value as bool);
    } else if (T == int) {
      await prefs.setInt(key, value as int);
    } else if (T == double) {
      await prefs.setDouble(key, value as double);
    }
    _cachedValues[key] = value;

    // Mark as customized if different from default
    final isCustomized = value != defaultValue;
    await prefs.setBool(customizedKey, isCustomized);
  }

  // Check if a setting is customized
  Future<bool> isCustomized(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key) ?? false;
  }

  Future<void> loadCache() async {
    final prefs = await SharedPreferences.getInstance();
    getSetting(
        kKeyPrimaryServer, kDefaultPrimaryServer, kKeyChangedPrimaryServer,
        prefs: prefs);
    getSetting(
        kKeyFallbackServer, kDefaultFallbackServer, kKeyChangedFallbackServer,
        prefs: prefs);
    getSetting(kKeyFallbackEnabled, kDefaultFallbackEnabled,
        kKeyChangedFallbackEnabled,
        prefs: prefs);
  }

  // Settings-specific methods for convenience
  Future<String> getPrimaryServer() async {
    return getSetting(
        kKeyPrimaryServer, kDefaultPrimaryServer, kKeyChangedPrimaryServer);
  }

  /// Returns the cached value
  String getPrimaryServerSync() {
    return _cachedValues[kKeyPrimaryServer]!;
  }

  Future<void> setPrimaryServer(String value) async {
    return setSetting(kKeyPrimaryServer, value, kDefaultPrimaryServer,
        kKeyChangedPrimaryServer);
  }

  Future<String> getFallbackServer() async {
    return getSetting(
        kKeyFallbackServer, kDefaultFallbackServer, kKeyChangedFallbackServer);
  }

  /// Returns the cached value
  String getFallbackServerSync() {
    return _cachedValues[kKeyFallbackServer]!;
  }

  Future<void> setFallbackServer(String value) async {
    return setSetting(kKeyFallbackServer, value, kDefaultFallbackServer,
        kKeyChangedFallbackServer);
  }

  Future<bool> getFallbackEnabled() async {
    return getSetting(kKeyFallbackEnabled, kDefaultFallbackEnabled,
        kKeyChangedFallbackEnabled);
  }

  /// Returns the cached value
  bool getFallbackEnabledSync() {
    return _cachedValues[kKeyFallbackEnabled]!;
  }

  Future<void> setFallbackEnabled(bool value) async {
    return setSetting(kKeyFallbackEnabled, value, kDefaultFallbackEnabled,
        kKeyChangedFallbackEnabled);
  }

  // Reset all settings
  Future<void> resetAllSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(kKeyPrimaryServer, kDefaultPrimaryServer);
    await prefs.setString(kKeyFallbackServer, kDefaultFallbackServer);
    await prefs.setBool(kKeyFallbackEnabled, kDefaultFallbackEnabled);
    await prefs.setBool(kKeyChangedPrimaryServer, false);
    await prefs.setBool(kKeyChangedFallbackServer, false);
    await prefs.setBool(kKeyChangedFallbackEnabled, false);
  }
}
