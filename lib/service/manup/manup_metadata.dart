import 'dart:io';

import 'package:flutter/foundation.dart';

class PlatformData {
  final String minVersion;
  final String latestVersion;
  final bool enabled;
  final String? updateUrl;

  PlatformData(
      {required this.minVersion,
      required this.latestVersion,
      required this.enabled,
      required this.updateUrl});

  static PlatformData fromJson(Map<String, dynamic> json) {
    return PlatformData(
      minVersion: json['minimum'],
      latestVersion: json['latest'],
      enabled: json['enabled'],
      updateUrl: json['url'],
    );
  }
}

class ManUpMetadata {
  final Map<String, dynamic> _data;

  ManUpMetadata(this._data);

  PlatformData getPlatformData(String platform) =>
      PlatformData.fromJson(_data[platform]);

  dynamic get(String key, {String? os}) =>
      _data[os ?? (kIsWeb ? 'web' : Platform.operatingSystem)]?[key] ??
      _data[key];

  T setting<T>(String key, {required T orElse, String? os}) =>
      (get(key, os: os) ?? orElse) as T;
}
