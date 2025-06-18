import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:http/io_client.dart';

bool enableSSLFix = false;

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
  } else if (enableSSLFix) {
    print("[HTTP] Using SSL fix");
    final SecurityContext context = SecurityContext(withTrustedRoots: true);
    var httpClient = HttpClient(context: context);
    httpClient.badCertificateCallback = checkBadCertificate;
    return IOClient(httpClient);
  }

  return Client();
}

bool checkBadCertificate(X509Certificate cert, String host, int port) {
  print("[HTTP] Checking certificate for $host");
  print("  Subject: ${cert.subject}");
  print("  Issuer: ${cert.issuer}");
  print("  SHA1: ${cert.sha1}");
  // print("  Valid from: ${cert.startValidity}");
  // print("  Valid to: ${cert.endValidity}");

  if (host != 'sweet.silkypants.dev') {
    print("[HTTP] Rejecting certificate for $host");
    return false;
  }
  if (cert.sha1.length != certSha1.length) {
    print("[HTTP] Rejecting certificate for $host: SHA1 length mismatch");
    return false;
  }
  for (var i = 0; i < cert.sha1.length; i++) {
    if (cert.sha1[i] != certSha1[i]) {
      print("[HTTP] Rejecting certificate for $host: SHA1 mismatch at $i");
      return false;
    }
  }
  print("[HTTP] Warning: Allowing untrusted certificate ${cert.subject} from ${cert.issuer} for $host");
  return true;
}
// The certificate for sweet.silkypants.dev seems to be signed by different
// versions of the Amazon Root CA 1. The normal version works, but on some
// clients the cross-signed version is used. This is the SHA1 of the Amazon
// root certificate that is signed by the Starfield root certificate. This
// certificate is being rejected by the default client.
// https://crt.sh/?id=11265962
// ToDo: Figure out why this is happening and fix it, see https://github.com/sweet-org/sweet/issues/25

final certSha1 = Uint8List.fromList([
  6, 178, 89, 39,
  196, 42, 114, 22,
  49, 193, 239, 217,
  67, 30, 100, 143,
  166, 46, 30, 57
]);