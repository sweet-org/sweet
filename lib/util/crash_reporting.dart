import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart' show FlutterError, kDebugMode;

import 'package:sweet/util/platform_helper.dart';

// ToDo: Clean this up, Firebase has been removed from the project
Future<void> initializeFirebase() async {

}

Future<void> logEvent({
  required String name,
  Map<String, Object>? parameters,
}) async {

}

void printToLog(String message) {
  print(message);


}

void reportError(
  dynamic exception,
  StackTrace? stackTrace, {
  Iterable<DiagnosticsNode> info = const [],
}) {
  print('Exception: $exception');

}
