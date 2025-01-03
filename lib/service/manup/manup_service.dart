import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sweet/service/manup/manup_metadata.dart';

import '../../util/version_tools.dart';

enum ManUpStatus {
  /// There was a problem fetching or validating the config file
  error,
  /// This is the latest version available (current version >= latestVersion)
  latest,
  /// This is a supported version (currentVersion >= minimumVersion) but a newer
  /// version is available.
  supported,
  /// This is an unsupported version (currentVersion < minimumVersion)
  unsupported,
  /// The app has been disabled for some reason (enabled is false in the config file)
  disabled,
  /// The status is unknown
  unknown,
}

class ManUpService {
  final String url;
  final Client http;
  final String os;

  ManUpStatus _status = ManUpStatus.unknown;

  ManUpStatus get status => _status;

  ManUpMetadata? _metadata;
  PlatformData? get configData => _metadata?.getPlatformData(os);

  ManUpService({required this.url, required this.http, String? os})
      : os = os ?? (kIsWeb ? 'web' : Platform.operatingSystem);

  Future<ManUpStatus> validate() async {
    print("ManUpService: Validating...");
    await _fetchConfig();
    if (_metadata == null) {
      print("ManUpService: Failed to fetch config");
      return _status;
    }
    await _validateVersion();
    print("ManUpService: Validation complete, status: $_status");
    return _status;
  }

  Future<void> _validateVersion() async {
    final platformData = configData;
    if (platformData == null) {
      _status = ManUpStatus.disabled;
      return;
    }
    if (!platformData.enabled) {
      _status = ManUpStatus.disabled;
      return;
    }

    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    Version currentVersion = Version.parse(packageInfo.version);
    Version minVersion = Version.parse(platformData.minVersion);
    Version latestVersion = Version.parse(platformData.latestVersion);

    if (currentVersion < minVersion) {
      _status = ManUpStatus.unsupported;
    } else if (currentVersion < latestVersion) {
      _status = ManUpStatus.supported;
    } else {
      _status = ManUpStatus.latest;
    }
    print("ManUpService: Current version: $currentVersion, "
        "min version: $minVersion, latest version: $latestVersion");
  }

  Future<void> _fetchConfig() async {
    try {
      final uri = Uri.parse(url);
      final response = await http.get(uri);
      if (response.statusCode != 200) {
        _status = ManUpStatus.error;
        print('ManUpService: Failed to fetch config from $url '
            'with status code ${response.statusCode}');
        return;
      }
      Map<String, dynamic> config = jsonDecode(response.body);
      _metadata = ManUpMetadata(config);
      //print('ManUpService: Fetched config from $url');
    } catch (e) {
      _status = ManUpStatus.error;
      print('ManUpService: Failed to fetch config from $url: $e');
      return;
    }
    return;
  }

  T setting<T>({required String key, required T orElse}) =>
      _metadata?.setting(key, orElse: orElse, os: os) ?? orElse;

  static String getMessage({required ManUpStatus status}) {
    switch (status) {
      case ManUpStatus.unsupported:
        return 'Mandatory update required';
      case ManUpStatus.supported:
        return 'App update available';
      case ManUpStatus.disabled:
        return 'App is not supported/disabled';
      case ManUpStatus.error:
        return 'Failed to check for updates';
      case ManUpStatus.latest:
        return 'App is up to date';
      case ManUpStatus.unknown:
        return 'Failed to check for updates';
    }
  }
}
