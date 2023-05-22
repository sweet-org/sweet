import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import 'package:path/path.dart' as path;
import 'package:qr_flutter/qr_flutter.dart';
import 'package:recase/recase.dart';

import 'package:sweet/util/localisation_constants.dart';
import 'package:sweet/mixins/file_selector_mixin.dart';

class QRCodeDialog extends StatelessWidget with FileSelector {
  QRCodeDialog({
    Key? key,
    required this.data,
    required this.title,
    this.leadingAction,
  }) : super(key: key);

  final _qrCodeKey = GlobalKey();

  final Widget? leadingAction;
  final String data;
  final String title;

  void copyCodeToClipboard() {
    Clipboard.setData(ClipboardData(text: data));
  }

  Future<void> _saveQRCode({required BuildContext context}) async {
    final saveFolder = await selectFolder();

    if (saveFolder == null) return;
    final savePath = path.join(saveFolder, '${title.snakeCase}.png');

    try {
      final boundary = _qrCodeKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;

      if (boundary != null) {
        final image = await boundary.toImage();
        final byteData = await image.toByteData(
          format: ui.ImageByteFormat.png,
        );

        if (byteData != null) {
          final qrCodeFile = File(savePath);
          await qrCodeFile.writeAsBytes(byteData.buffer.asUint8List());
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Save QR code: $savePath'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not save QR code'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(64.0),
      child: AlertDialog(
        title: Center(child: Text(title)),
        contentPadding: EdgeInsets.all(8),
        content: SizedBox.fromSize(
          size: Size.square(208),
          child: Center(
            child: RepaintBoundary(
              key: _qrCodeKey,
              child: QrImageView(
                padding: EdgeInsets.all(8),
                backgroundColor: Colors.white,
                data: data,
                version: QrVersions.auto,
              ),
            ),
          ),
        ),
        insetPadding: EdgeInsets.zero,
        actions: <Widget>[
          leadingAction ?? Container(),
          TextButton(
            onPressed: copyCodeToClipboard,
            child: Text(StaticLocalisationStrings.copyCode),
          ),
          TextButton(
            onPressed: () => _saveQRCode(context: context),
            child: Text('Save QR Code'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(StaticLocalisationStrings.close),
          ),
        ],
      ),
    );
  }
}
