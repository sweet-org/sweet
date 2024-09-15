import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart' show FlutterError, kDebugMode;

import 'package:sweet/util/platform_helper.dart';
import 'package:sweet/firebase_options.dart';

Future<void> initializeFirebase() async {
  if (PlatformHelper.hasFirebase) {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

    if (kDebugMode) {
      // Force disable Crashlytics collection while doing every day development.
      // Temporarily toggle this to true if you want to test crash reporting in your app.
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
    } else {
      FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
    }
  }
}

Future<void> logEvent({
  required String name,
  Map<String, Object>? parameters,
}) {
  return FirebaseAnalytics.instance.logEvent(
    name: name,
    parameters: parameters,
  );
}

void printToLog(String message) {
  print(message);

  if (PlatformHelper.hasFirebase) {
    FirebaseCrashlytics.instance.log(message);
  }
}

void reportError(
  dynamic exception,
  StackTrace? stackTrace, {
  Iterable<DiagnosticsNode> info = const [],
}) {
  print('Exception: $exception');

  if (PlatformHelper.hasFirebase) {
    FirebaseCrashlytics.instance.recordError(
      exception,
      stackTrace,
      information: info,
    );
  }
}
