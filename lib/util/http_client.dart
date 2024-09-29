import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:http/io_client.dart';

Client createHttpClient({bool enableProxy = false}) {
  if (kDebugMode && enableProxy) {
    // Make sure to replace <YOUR_LOCAL_IP> with
    // the external IP of your computer if you're using Android.
    // Note that we're using port 8888 which is Charles' default.
    var proxy = Platform.isAndroid ? '<YOUR_LOCAL_IP>:8888' : 'localhost:8888';

    // Create a new HttpClient instance.
    var httpClient = HttpClient();

    // Hook into the findProxy callback to set
    // the client's proxy.
    httpClient.findProxy = (uri) {
      return 'PROXY $proxy;';
    };

    // This is a workaround to allow Charles to receive
    // SSL payloads when your app is running on Android
    httpClient.badCertificateCallback =
    ((X509Certificate cert, String host, int port) => Platform.isAndroid);

    return IOClient(httpClient);
  }

  return Client();
}