import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';

import 'package:sweet/util/platform_helper.dart';

mixin FileSelector {
  Future<String?> selectFolder() async {
    String? path;
    try {
      if (PlatformHelper.isMobile) {
        final canUseStorage = await Permission.storage.isGranted;
        if (!canUseStorage) {
          // The user opted to never again see the permission request dialog for this
          // app. The only way to change the permission's status now is to let the
          // user manually enable it in the system settings.
          await openAppSettings();
          return null;
        }
      }
      final result = await FilePicker.platform.getDirectoryPath();

      if (result != null) {
        path = result;
      }
    } catch (e) {
      print(e);
    }

    print('File Selected: ${path ?? '[None]'}');

    return path;
  }

  Future<String?> selectFile() async {
    String? path;
    try {
      if (PlatformHelper.isMobile) {
        final canUseStorage = await Permission.storage.isGranted;
        if (!canUseStorage) {
          // The user opted to never again see the permission request dialog for this
          // app. The only way to change the permission's status now is to let the
          // user manually enable it in the system settings.
          await openAppSettings();
          return null;
        }
      }

      final result = await FilePicker.platform.pickFiles();
      path = result?.files.single.path;
    } catch (e) {
      print(e);
    }

    print('File Selected: ${path ?? '[None]'}');

    return path;
  }

  Future<String?> loadQrCode() async {
    // TODO: How to load QR code from file?!?
    // final filePath = await selectFile();
    return null;
  }
}
