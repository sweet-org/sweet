import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:expressions/expressions.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:archive/archive.dart';
import 'package:http/http.dart' as http;
import 'package:sweet/bloc/item_repository_bloc/market_group_filters.dart';
import 'package:sweet/model/fitting/fitting_implant_module.dart';
import 'package:sweet/model/fitting/fitting_nanocore.dart';
import 'package:sweet/model/fitting/fitting_nanocore_affix.dart';
import 'package:sweet/model/fitting/fitting_rig_integrator.dart';
import 'package:sweet/model/implant/implant_fitting_slot_module.dart';
import 'package:sweet/model/implant/implant_loadout_definition.dart';
import 'package:sweet/model/implant/slot_type.dart';
import 'package:sweet/model/nihilus_space_modifier.dart';
import 'package:sweet/model/ship/ship_fitting_slot_module.dart';
import 'package:sweet/service/settings_service.dart';
import 'package:sweet/util/http_client.dart';

import '../extensions/item_meta_extension.dart';

import '../bloc/data_loading_bloc/data_loading.dart';

import '../util/constants.dart';
import '../util/platform_helper.dart';

import '../database/database_exports.dart';
import '../database/database_mobile.dart';
import '../database/entities/entities.dart' as eve;

import '../model/character/learned_skill.dart';

import '../model/fitting/fitting.dart';
import '../model/fitting/fitting_drone.dart';
import '../model/fitting/fitting_item.dart';
import '../model/fitting/fitting_module.dart';
import '../model/fitting/fitting_ship.dart';
import '../model/fitting/fitting_skill.dart';

import '../model/items/eve_echoes_categories.dart';

import '../model/ship/eve_echoes_attribute.dart';
import '../model/ship/ship_loadout_definition.dart';
import '../model/ship/module_state.dart';
import '../model/ship/ship_fitting_loadout.dart';
import '../model/ship/slot_type.dart';

import '../model/implant/implant_fitting_loadout.dart';
import '../model/fitting/fitting_implant.dart';

import '../service/fitting_simulator.dart';
import '../service/attribute_calculator_service.dart';

import '../util/crc32.dart' as crc;

part 'item_repository_fitting.dart';
part 'item_repository_db_functions.dart';
part 'item_repository_implant.dart';

typedef DownloadProgressCallback = void Function(int, int);

class ItemRepository {
  Map<int, MarketGroup> marketGroupMap = {};
  Map<int, GoldNanoAttrClass> goldAttrFirstClassMap = {};
  Map<int, GoldNanoAttrClass> goldAttrSecondClassMap = {};
  Map<int, Expression> levelAttributeMap = {};
  List<int> _excludeFusionRigs = [];
  List<int> get excludeFusionRigs => _excludeFusionRigs;

  final Map<int, Item> _itemsCache = {};
  final Map<int, Attribute> _attributeCache = {};

  int get skillItemsCount => fittingSkills.values.length;

  final EveEchoesDatabase _echoesDatabase = EveEchoesDatabase();
  String _currentLanguageCode = 'en';
  EveEchoesDatabase get db => _echoesDatabase;
  Map<int, FittingSkill> fittingSkills = {};

  Future<bool> checkForDatabaseUpdate({
    required int latestVersion,
    required bool checkEtag,
    required int dbCrc,
    bool performCrcCheck = false,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final dbVersion = prefs.getInt('dbVersion');
    final dbIsOK = await dbOK(
      checkEtag: checkEtag,
      dbCrc: dbCrc,
      performCrcCheck: performCrcCheck,
    );
    print("DB check completed: dbVersion=$dbVersion, latestVersion=$latestVersion, dbOk=$dbIsOK");
    return dbVersion == null || dbVersion != latestVersion || !dbIsOK;
  }

  Future<bool> dbOK({
    required bool checkEtag,
    required int dbCrc,
    required bool performCrcCheck,
  }) async {
    final dbFile = await PlatformHelper.dbFile();
    final isOK = await dbFile.exists();

    if (!isOK) return false;

    if (checkEtag) {
      final client = createHttpClient();
      late http.StreamedResponse response;
      late dynamic dbEtag;

      try {
        String baseUrl = await SettingsService().getPrimaryServer();
        if (baseUrl.endsWith("/")) {
          baseUrl = baseUrl.replaceAll(RegExp("/*\$"), "");
        }
        final dbUrl = Uri.parse(baseUrl + kDBUrl);
        final res = await client.send(http.Request('HEAD', dbUrl));
        if (res.statusCode != 200) {
          throw http.ClientException(
              'Invalid Status code: ${res.statusCode}', dbUrl);
        }
        final etag = res.headers['etag'];
        response = res;
        dbEtag = etag;
      } catch (e) {
        print("Primary server failed for db check: $e");
        if (e is! http.ClientException) {
          rethrow;
        }

        final hasFallback = await SettingsService().getFallbackEnabled();
        if (!hasFallback) {
          throw Exception('Failed to check database: $e');
        }
        print("Primary server failed, trying fallback: $e");

        String baseUrl = await SettingsService().getFallbackServer();
        if (baseUrl.endsWith("/")) {
          baseUrl = baseUrl.replaceAll(RegExp("/*\$"), "");
        }
        final dbUrl = Uri.parse(baseUrl + kDBUrl);
        final res = await client.send(http.Request('HEAD', dbUrl));
        final etag = res.headers['etag'];
        response = res;
        dbEtag = etag;
      }

      if (response.statusCode >= 400) {
        throw Exception('Invalid Status code: ${response.statusCode}');
      }

      final prefs = await SharedPreferences.getInstance();
      final storedEtag = prefs.getString('dbEtag');

      if (dbEtag == null) {
        throw Exception(
            'ETag is missing: \n ${response.headers.keys.join(', ')}');
      }
      if (storedEtag != dbEtag) {
        print("DB not ok: storedEtag != dbEtag ($storedEtag != $dbEtag)");
        return false;
      }
    }

    if (performCrcCheck) {
      final crc32 = await databaseCrc();
      if (crc32 != dbCrc) print("DB not ok: crc mismatch, local != remote: $crc32 != $dbCrc");
      return crc32 == dbCrc;
    }

    return true;
  }

  Future<int> databaseCrc() async {
    final dbFile = await PlatformHelper.dbFile();

    final isOK = await dbFile.exists();

    if (!isOK) {
      throw Exception('Database is missing');
    }

    final bytes = await dbFile.readAsBytes();
    final crc32 = await compute(calculateCrc, bytes);
    return crc32;
  }

  Future<http.StreamedResponse> _downloadDb({
    required String baseUrl,
}) async {
    String dbUrl = baseUrl.replaceAll(RegExp("/*\$"), "") + kDBUrl;
    final dbTestUrl = Uri.parse(dbUrl);
    print('Downloading DB from $dbTestUrl');

    var response = await createHttpClient().send(http.Request('GET', dbTestUrl));

    if (response.statusCode >= 400) {
      throw http.ClientException(
          'Invalid Status code: ${response.statusCode}', dbTestUrl);
    }

    return response;
  }

  Future<void> downloadDatabase({
    required int latestVersion,
    required Emitter<DataLoadingBlocState> emitter,
  }) async {
    final dbFile = await PlatformHelper.dbFile();
    final prefs = await SharedPreferences.getInstance();

    // Download the latest DB
    print('Downloading DB...');
    emitter(LoadingRepositoryState('Downloading DB for v$latestVersion...'));

    late http.StreamedResponse response;
    bool isPrimary = true;
    try {
      final res = await _downloadDb(
        baseUrl: await SettingsService().getPrimaryServer(),
      );
      response = res;
    } catch (e) {
      if (e is! http.ClientException) {
        rethrow;
      }
      final hasFallback = await SettingsService().getFallbackEnabled();
      if (!hasFallback) {
        throw Exception('Failed to download database: $e');
      }
      print("Primary server failed, trying fallback: $e");
      response = await _downloadDb(
        baseUrl: await SettingsService().getFallbackServer(),
      );
      isPrimary = false;
    }

    var totalBytes = response.contentLength;
    var downloadedBytes = 0;
    var bytes = <int>[];

    var stream = response.stream;

    await for (var value in stream) {
      bytes.addAll(value);
      downloadedBytes += value.length;
      emitter(DownloadingDatabaseState(
        downloadedBytes: downloadedBytes,
        totalBytes: totalBytes!,
        message:
            'Downloading Database ${isPrimary ? "" : "from fallback"}\n'
            '${filesize(downloadedBytes, 2)} of ${filesize(totalBytes, 2)}',
      ));
    }

    emitter(LoadingRepositoryState('Decompressing DB...'));
    await compute(decompressDbArchive, bytes).then((tarData) {
      print('Writing DB to ${dbFile.path}');
      return dbFile.writeAsBytes(tarData, flush: true);
    }).then((writtenFile) {
      print('Written DB to ${writtenFile.path}');

      final dbEtag = response.headers['etag'];
      if (dbEtag == null) return Future.value(true);
      return prefs.setString('dbEtag', dbEtag);
    });
  }

  Future<void> openDatabase() async {
    final dbFile = await PlatformHelper.dbFile();

    if (!dbFile.existsSync()) {
      throw Exception('DB missing at ${dbFile.path}');
    }

    await _echoesDatabase.openDatabase(path: dbFile.absolute.path);

    bool needsWriteMode = false;

    if (!await hasModifierSkillCache()) {
      needsWriteMode = true;
    }

    if (!await hasMarketGroupIndex()) {
      needsWriteMode = true;
    }

    if (needsWriteMode) {
      await db.closeDatabase();
      await _echoesDatabase.openDatabase(path: dbFile.absolute.path, readOnly: false);

      if (!await hasModifierSkillCache()) {
        print("Creating modifier skill cache...");
        await createModifierSkillColumn();
        await genModifierSkillCache();
      }

      if (!await hasMarketGroupIndex()) {
        print("Creating market group index...");
        await createMarketGroupIndex();
      }

      await _echoesDatabase.closeDatabase();
      await _echoesDatabase.openDatabase(path: dbFile.absolute.path);
    } else {
      print("Modifier skill cache and market group index already exist, skipping creation");
    }

    fittingSkills = {
      for (var s in await fittingSkillsFromDbSkills()) s.itemId: s
    };

    unawaited(nSpaceModifiers().then((value) => nSpaceMods = value));
    unawaited(implantShieldArmorModifiers().then(
            (value) => implantShieldArmorMods = value));

    final prefs = await SharedPreferences.getInstance();
    final dbVersion = await _echoesDatabase.getVersion();
    final savedDbVersion = prefs.getInt('dbVersion');
    if (savedDbVersion != dbVersion) {
      await prefs.setInt('dbVersion', dbVersion);
    }
  }

  var nSpaceMods = <NihilusSpaceModifier>[];
  var implantShieldArmorMods = <ItemModifier>[];

  bool setCurrentLanguage(String langCode) {
    _currentLanguageCode = langCode;

    return true;
  }

  Future<void> processMarketGroups() async {
    var mkgs = await _echoesDatabase.marketGroupDao.selectAll();
    marketGroupMap = {for (var m in mkgs) m.id: m};
    for (var mkg in marketGroupMap.values) {
      var items = await itemsForMarketGroup(marketGroupId: mkg.id);
      if (items.isNotEmpty) {
        mkg.items = items.toList();
      }

      if (mkg.parentId != null) {
        marketGroupMap[mkg.parentId!]!.children.add(mkg);
      }
    }
  }

  Future<void> processLevelAttributes() async {
    var lvlAttrs = await _echoesDatabase.levelAttributeDao.selectAll();
    levelAttributeMap = {};
    for (var lvlAttr in lvlAttrs) {
      levelAttributeMap[lvlAttr.attrId] = Expression.parse(lvlAttr.formula);
    }
  }

  Future<void> processGoldNanoAttrClasses() async {
    /*
     * The hierarchy for the nanocore affixes that
     * has to be loaded is as follows:
     *
     * GoldNanoAttrClass (first)
     *  - children: GoldNanoAttrClass (second)
     *     - items: ItemNanocoreAffix (group/level 0)
     *        - item: Item (for localisation)
     *        - children: ItemNanocoreAffix (level 1+)
     */
    var classes = await _echoesDatabase.goldNanoAttrClassDao.selectAll();
    goldAttrFirstClassMap = {};
    goldAttrSecondClassMap = {};
    for (var attrClass in classes) {
      if (attrClass.classLevel == 1) {
        goldAttrFirstClassMap[attrClass.classId] = attrClass;
        continue;
      }
      if (attrClass.classLevel != 2) {
        print("Error, invalid class level for ${attrClass.classId}-${attrClass.classLevel}");
        continue;
      }
      goldAttrSecondClassMap[attrClass.classId] = attrClass;
    }
    final attrIds = <int>[];
    for (var attrClass in goldAttrSecondClassMap.values) {
      goldAttrFirstClassMap[attrClass.parentClassId]!.children.add(attrClass);

      var affixes = await nanocoreAffixesForSecondClass(
          classId: attrClass.classId);
      if (affixes.isEmpty) continue;
      affixes = affixes.toList();
      final sortedAffixes = <int, ItemNanocoreAffix>{};
      for (var affix in affixes) {
        if (affix.attrGroup == affix.attrId) {
          affix.children = [];
          sortedAffixes[affix.attrId] = affix;
          attrIds.add(affix.attrId);
        }
      }
      attrClass.items = [];
      for (var affix in affixes) {
        if (affix.children != null) {
          attrClass.items!.add(affix);
          continue;
        }

        final parent = sortedAffixes[affix.attrGroup];
        if (parent == null) {
          print("Error, nanocore affix ${affix.attrId} has unknown group ${affix.attrGroup}");
          continue;
        }

        parent.children!.add(affix);
      }
    }
    final items = await itemsWithIds(ids: attrIds);
    final itemsMap = {for (var i in items) i.id: i};
    for (var attrClass in goldAttrSecondClassMap.values) {
      if (attrClass.items == null) continue;

      for (var affix in attrClass.items!) {
        var item = itemsMap[affix.attrId];
        if (item == null) {
          print("Error, nanocore affix ${affix.attrId} has no item");
          continue;
        }
        affix.item = item;
      }
    }
  }

  Future<void> processExcludeFusionRigs() async {
    // There are rigs (at the time of writing only the higgs anchors), that
    // can't be integrated and have to get filtered out of the fitting menu for
    // integrated rigs.
    _excludeFusionRigs = [for (var id in await getExcludeFusionRigs()) id];
  }

  Future<Iterable<FittingSkill>> fittingSkillsFromDbSkills() async {
    final skills = await skillItems;

    final ids = skills.map((e) => e.id);
    final items = {for (var item in skills) item.id: item};

    // Get all the attributes
    final itemAttributes = await getBaseAttributesForItemIds(ids);

    // Get all the modifiers
    final modifiers = await getModifiersForSkillIds(ids);

    return ids.map(
      (e) => FittingSkill(
        item: items[e]!, // Safe as the items are known
        baseAttributes: itemAttributes[e]?.toList() ?? [],
        modifiers: modifiers[e]?.toList() ?? [],
        skillLevel: 5,
      ),
    );
  }
}

List<int> decompressDbArchive(List<int> bytes) {
  print('Decompressing DB...');
  final bzipData = BZip2Decoder().decodeBytes(bytes);
  print('Decoding DB Tar ...');
  final tarData = TarDecoder().decodeBytes(bzipData);
  return tarData.files.firstOrNull?.content ?? [];
}

int calculateCrc(List<int> bytes) {
  return crc.CRC32.compute(bytes).toSigned(32);
}
