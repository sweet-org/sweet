import 'dart:async';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScanner extends StatefulWidget {
  QrScanner({Key? key}) : super(key: key);

  @override
  State<QrScanner> createState() => _QrScannerState();
}

class _QrScannerState extends State<QrScanner> {
  final MobileScannerController  _captureController = MobileScannerController();

  final picker = ImagePicker();

  bool _isTorchOn = false;

  @override
  void initState() {
    super.initState();
    unawaited(_captureController.start());
  }

  @override
  Future<void> dispose() async {
    super.dispose();
    await _captureController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          MobileScanner(
            controller: _captureController,
            onDetect: (data) => onScannedData(data.barcodes.first.rawValue),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: _buildToolBar(),
          )
        ],
      ),
    );
  }

  Widget _buildToolBar() {
    return SafeArea(
      child: Container(
        height: 64,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              RawMaterialButton(
                onPressed: () => onScannedData(null),
                fillColor: Colors.blue.shade700,
                shape: CircleBorder(),
                child: Center(
                    child: Icon(
                  Icons.close,
                  color: Colors.white,
                )),
              ),
              RawMaterialButton(
                onPressed: () {
                  _captureController.toggleTorch();

                  setState(() {
                    _isTorchOn = !_isTorchOn;
                  });
                },
                fillColor: Colors.blue.shade700,
                shape: CircleBorder(),
                child: Center(
                    child: Icon(
                  _isTorchOn ? Icons.lightbulb : Icons.lightbulb_outline,
                  color: Colors.white,
                )),
              ),
              RawMaterialButton(
                onPressed: () async {
                  var pickedFile =
                      await picker.pickImage(source: ImageSource.gallery);

                  var data = pickedFile != null
                      ? await _captureController.analyzeImage(pickedFile.path)
                      : null;
                  onScannedData(data?.barcodes.first.rawValue);
                },
                fillColor: Colors.blue.shade700,
                shape: CircleBorder(),
                child: Center(
                    child: Icon(
                  Icons.image,
                  color: Colors.white,
                )),
              )
            ],
          ),
        ),
      ),
    );
  }

  void onScannedData(String? data) {
    print('onCapture----$data');
    _captureController.pause();
    Navigator.of(context).pop(data);
  }
}
