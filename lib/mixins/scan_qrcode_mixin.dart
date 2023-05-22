import 'package:flutter/material.dart';
import 'package:sweet/widgets/qr_scanner.dart';

typedef QrCodeCallback = void Function(String? data);

mixin ScanQrCode {
  void scanQrCode({
    required BuildContext context,
    required QrCodeCallback onScan,
  }) async {
    final results = await Navigator.push(
      // waiting for the scan results
      context,
      MaterialPageRoute(
        builder: (context) => QrScanner(), // open the scan view
      ),
    );
    onScan(results);
  }
}
