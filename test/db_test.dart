import 'package:collection/collection.dart';
import 'package:flutter_test/flutter_test.dart';

// ignore: depend_on_referenced_packages
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sweet/model/ship/eve_echoes_attribute.dart';
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

    test(
      'Ensure hardcoded attributes exist',
      () async {
        // Batch size for database queries
        const int batchSize = 20;

        // Get all attributes as a list
        final allAttributes = EveEchoesAttribute.values.toList();

        // A list to keep track of missing attributes
        final missingAttributes = <EveEchoesAttribute>[];

        // Process attributes in batches
        for (int i = 0; i < allAttributes.length; i += batchSize) {
          final end = (i + batchSize < allAttributes.length)
              ? i + batchSize
              : allAttributes.length;

          final batchAttributes = allAttributes.sublist(i, end);
          final batchIds = batchAttributes
              .map((attr) => attr.attributeId)
              .whereNot((id) => id < 0)
              .toList();

          final dbAttributes =
              await itemRepo.attributesWithIdsNullable(ids: batchIds);
          final foundIds = dbAttributes.nonNulls.map((attr) => attr.id).toSet();

          // Check which attributes from this batch are missing in the database
          for (final attr in batchAttributes) {
            if (attr.attributeId < 0) continue;
            if (!foundIds.contains(attr.attributeId)) {
              missingAttributes.add(attr);
            }
          }
        }

        // Format error message if there are missing attributes
        if (missingAttributes.isNotEmpty) {
          final missingList = missingAttributes
              .map((attr) => '${attr.name} (ID: ${attr.attributeId})')
              .join('\n  - ');

          fail(
              'The following attributes are missing in the database:\n  - $missingList');
        }

        expect(missingAttributes, isEmpty,
            reason: 'All hardcoded attributes should exist in database');
      },
    );
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
