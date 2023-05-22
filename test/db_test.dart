import 'package:flutter_test/flutter_test.dart';
// ignore: depend_on_referenced_packages
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sweet/repository/item_repository.dart';
import 'package:sweet/util/platform_helper.dart';

import 'mock_platform_paths.dart';
import 'package:sweet/util/crc32.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    PathProviderPlatform.instance = MockPathProviderPlatform();
    SharedPreferences.setMockInitialValues({}); //set values here
  });

  test(
    'Ensure DB CRC is correct',
    () async {
      final dbFile = await PlatformHelper.dbFile();

      final dbFileExists = await dbFile.exists();
      expect(dbFileExists, true);

      final time = DateTime.now();
      final crc32 = CRC32.compute(dbFile.readAsBytesSync()).toSigned(32);
      expect(crc32, 0x7a4ffbfc);
      final time2 = DateTime.now();
      print('$crc32 in ${time2.difference(time)}');
    },
    skip: 'This should only be run manually, as the CRC will change',
  );

  group('Data tests >', () {
    var itemRepo = ItemRepository();

    setUpAll(() async {
      // Load item repo
      print('Loading files');
      await itemRepo.openDatabase();
    });

    // test(
    //   'Ensure Item Searching works',
    //   () async {
    //     final hammerHeadItems =
    //         await itemRepo.itemsFilteredOnName(filter: 'MK9 Hammerhead');
    //     expect(hammerHeadItems.length, 2); // Drone + Blueprint

    //     final longbowItems =
    //         await itemRepo.itemsFilteredOnName(filter: 'Longbow');
    //     expect(longbowItems.length, 1);
    //   },
    // );
  });
}
