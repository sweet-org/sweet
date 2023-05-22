import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:sweet/util/platform_helper.dart';

import 'database.dart';

extension EveEchoesDatabaseMobile on EveEchoesDatabase {
  Future<void> openDatabase({
    required String path,
    bool readOnly = true,
  }) async {
    if (PlatformHelper.isMobile) {
      db = await sqflite.openDatabase(path, readOnly: readOnly);
    } else {
      sqfliteFfiInit();
      var databaseFactory = databaseFactoryFfi;
      final options = sqflite.OpenDatabaseOptions(readOnly: readOnly);
      db = await databaseFactory.openDatabase(
        path,
        options: options,
      );

      final dbVersion = await db.getVersion();
      print('DB version: $dbVersion');
    }
    print('Opening DB at ${db.path}');
  }
}
