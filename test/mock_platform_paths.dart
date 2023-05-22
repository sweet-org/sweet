import 'dart:io';

import 'package:mockito/mockito.dart';
// ignore: depend_on_referenced_packages
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
// ignore: depend_on_referenced_packages
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:path/path.dart' show dirname, join;

const String kTemporaryPath = 'test/data/temp';
const String kApplicationSupportPath = 'test/data/app_support';
const String kDownloadsPath = 'test/data/downloads';
const String kLibraryPath = 'test/data/library';
const String kApplicationDocumentsPath = 'test/data/docs';
const String kExternalCachePath = 'test/data/ext_cache';
const String kExternalStoragePath = 'test/data/ext_storage';

class MockPathProviderPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  String get scriptDir =>
      dirname(Platform.script.toFilePath(windows: Platform.isWindows));
  @override
  Future<String> getTemporaryPath() async {
    return join(scriptDir, kTemporaryPath);
  }

  @override
  Future<String> getApplicationSupportPath() async {
    return join(scriptDir, kApplicationSupportPath);
  }

  @override
  Future<String> getLibraryPath() async {
    return join(scriptDir, kLibraryPath);
  }

  @override
  Future<String> getApplicationDocumentsPath() async {
    return join(scriptDir, kApplicationDocumentsPath);
  }

  @override
  Future<String> getExternalStoragePath() async {
    return join(scriptDir, kExternalStoragePath);
  }

  @override
  Future<List<String>> getExternalCachePaths() async {
    return <String>[join(scriptDir, kExternalCachePath)];
  }

  @override
  Future<List<String>> getExternalStoragePaths({
    StorageDirectory? type,
  }) async {
    return <String>[join(scriptDir, kExternalStoragePath)];
  }

  @override
  Future<String> getDownloadsPath() async {
    return join(scriptDir, kDownloadsPath);
  }
}
