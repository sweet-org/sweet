import 'dart:async';

// This is OK - as these will all be refactored in the new package
// ignore: depend_on_referenced_packages
import 'package:sqflite_common/sqlite_api.dart';

import 'daos/daos.dart';

class EveEchoesDatabase {
  late Database db;

  late AttributeDao attributeDao;
  late EffectDao effectDao;
  late ItemAttributeDao itemAttributeDao;
  late ItemBonusTexDao itemBonusTexDao;
  late ItemEffectDao itemEffectDao;
  late ItemModifierDao itemModifierDao;
  late ItemNanocoreDao itemNanocoreDao;
  late ItemDao itemDao;
  late LocalisedStringDao localisedStringDao;

  late CategoryDao categoryDao;
  late GroupDao groupDao;

  late NpcEquipmentDao npcEquipmentDao;
  late MarketGroupDao marketGroupDao;

  late ShipModesDao shipModesDao;
  late ShipNanocoreDao shipNanocoreDao;

  late UnitDao unitDao;

  late List<BaseDao> _allDaos;

  EveEchoesDatabase() {
    attributeDao = AttributeDao(this);
    effectDao = EffectDao(this);
    itemAttributeDao = ItemAttributeDao(this);
    itemBonusTexDao = ItemBonusTexDao(this);
    itemEffectDao = ItemEffectDao(this);
    itemModifierDao = ItemModifierDao(this);
    itemNanocoreDao = ItemNanocoreDao(this);
    itemDao = ItemDao(this);
    localisedStringDao = LocalisedStringDao(this);
    categoryDao = CategoryDao(this);
    groupDao = GroupDao(this);
    npcEquipmentDao = NpcEquipmentDao(this);
    marketGroupDao = MarketGroupDao(this);
    shipModesDao = ShipModesDao(this);
    shipNanocoreDao = ShipNanocoreDao(this);
    unitDao = UnitDao(this);

    _allDaos = [
      attributeDao,
      effectDao,
      itemAttributeDao,
      itemBonusTexDao,
      itemEffectDao,
      itemModifierDao,
      itemNanocoreDao,
      itemDao,
      localisedStringDao,
      categoryDao,
      groupDao,
      npcEquipmentDao,
      marketGroupDao,
      shipModesDao,
      shipNanocoreDao,
      unitDao,
    ];
  }

  /// Drop and recreate all DAO tables
  void nukeDatabase() {
    for (var dao in _allDaos) {
      dao.dropTable();
      dao.createTable();
    }
  }

  Future<void> closeDatabase() async {
    await db.close();
  }

  Future<int> setVersion(int version) async {
    await db.rawQuery('PRAGMA user_version = $version');

    return getVersion();
  }

  Future<int> getVersion() async {
    final rows = await db.rawQuery('PRAGMA user_version');
    if (rows.isEmpty || rows.first.isEmpty) return 0;
    return rows.first['user_version'] as int? ?? 0;
  }
}
