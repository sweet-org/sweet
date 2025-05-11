import 'dart:io';
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'package:flutter/foundation.dart' show kDebugMode;

class PlatformHelper {
  static bool isDarkMode(context) =>
      MediaQuery.of(context).platformBrightness == Brightness.dark;

  static bool get isMobile => (Platform.isAndroid || Platform.isIOS);
  static bool get hasFirebase => false;
  static bool get isDesktop =>
      (Platform.isWindows || Platform.isMacOS || Platform.isLinux);
  static bool get shouldCopyDB => (isMobile || Platform.isMacOS);

  static String get scriptPath =>
      Platform.script.toFilePath(windows: Platform.isWindows);

  static bool get isDebug => kDebugMode;

  static Future<Directory> _dbDirectory() async {
    if (!shouldCopyDB && kDebugMode) {
      /// This unfortunately does not work for MacOS, so 'live development'
      /// will be a bit trickier there (though hopefully this will not be
      /// required)
      print('Loading from ${dirname(scriptPath)}/test/data/app_support');
      return Directory('${dirname(scriptPath)}/test/data/app_support');
    }

    return getApplicationSupportDirectory();
  }

  static Future<File> dbFile() async {
    final dir = await _dbDirectory();
    return File(join(dir.path, 'echoes.db'));
  }

  static Future<File> logFile() async {
    final dir = await _dbDirectory();
    return File(join(dir.path, 'log.txt'));
  }

  static Future<bool> shouldEnableLogging() async {
    final dir = await _dbDirectory();
    final file = File(join(dir.path, 'enableLog'));
    if (await file.exists()) {
      return true;
    }
    return false;
  }

  static Future<bool> shouldEnableSSLFix() async {
    final dir = await _dbDirectory();
    final file = File(join(dir.path, 'enableSSLFix'));
    if (await file.exists()) {
      print("SSL fix should be enabled, file in support dir found");
      return true;
    } else {
      print("SSL fix: file not found in support dir");
    }
    try {
      final data = await rootBundle.loadString('assets/enableSSLFix');
      if (data.toLowerCase().startsWith("true")) {
        print("SSL fix should be enabled because of assets/enableSSLFix");
        return true;
      }
      print("SSL fix: assets/enableSSLFix found but not set to true");
    } catch (e) {
      print("SSL fix: assets/enableSSLFix not found: $e");
    }
    print("SSL fix should not be enabled");
    return false;
  }
}
