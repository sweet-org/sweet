part of 'item_repository.dart';

extension ItemRepositoryDb on ItemRepository {
  Future<Attribute?> attributeWithId({required int id}) async {
    if (id < 0) {
      return Attribute.fromStaticId(id: id);
    }

    if (_attributeCache.containsKey(id)) {
      return _attributeCache[id];
    }

    var attribute = await _echoesDatabase.attributeDao.selectWithId(id: id);
    if (attribute != null) {
      _attributeCache[attribute.id] = attribute;
    }

    return attribute;
  }

  Future<Iterable<Attribute>> attributesWithIds(
      {required List<int> ids}) async {
    var missingAttributes =
        ids.where((id) => _attributeCache.containsKey(id) == false);

    if (missingAttributes.isNotEmpty) {
      var attributes =
          await _echoesDatabase.attributeDao.selectWithIds(ids: ids);
      for (var attr in attributes) {
        _attributeCache[attr.id] = attr;
      }
    }

    return ids.map((id) => _attributeCache[id]!);
  }

  Future<Iterable<Attribute?>> attributesWithIdsNullable(
      {required List<int> ids}) async {
    var missingAttributes =
    ids.where((id) => _attributeCache.containsKey(id) == false);

    if (missingAttributes.isNotEmpty) {
      var attributes =
      await _echoesDatabase.attributeDao.selectWithIds(ids: ids);
      for (var attr in attributes) {
        _attributeCache[attr.id] = attr;
      }
    }

    return ids.map((id) => _attributeCache[id]);
  }

  Future<Effect?> effectWithId({required int? id}) async =>
      await _echoesDatabase.effectDao.selectWithId(id: id);

  Future<Unit?> unitWithId({required int id}) async =>
      await _echoesDatabase.unitDao.selectWithId(id: id);

  Future<Iterable<LevelAttribute>> levelAttributes() async =>
      await _echoesDatabase.levelAttributeDao.selectAll();

  Future<Iterable<eve.Category>> categories(
          {bool includeEmpty = false}) async =>
      await (includeEmpty
          ? _echoesDatabase.categoryDao.selectAll()
          : _echoesDatabase.categoryDao.selectAllNonEmpty());

//   Future<eve.Category?> categoryWithId({required int id}) async =>
//       await _echoesDatabase.categoryDao.selectWithId(id: id);

//   Future<Group?> groupWithId({required int id}) async =>
//       await _echoesDatabase.groupDao.selectWithId(id: id);

  Future<Iterable<Group>> groupsForCategory({
    required int id,
    bool includeEmpty = false,
    bool includeItems = false,
  }) async {
    var groups = await _echoesDatabase.groupDao
        .selectWithCategory(categoryId: id, includeEmpty: includeEmpty);

    if (includeItems) {
      groups = await Future.wait(
        groups.map(
          (group) async {
            var items = await itemsForGroup(
                groupId: group.id, includeUnpublished: false);
            return Group.clone(
              group,
              items.toList(),
            );
          },
        ),
      );
    }

    return groups;
  }

  Future<Iterable<Group>> skillGroups({bool includeItems = false}) async =>
      await groupsForCategory(id: 49, includeItems: includeItems);

  Future<Iterable<Item>> get skillItems async =>
      await _echoesDatabase.itemDao.selectWithCategory(categoryId: 49);

  Future<Item?> itemWithId({required int id}) async {
    if (_itemsCache.containsKey(id)) {
      return _itemsCache[id];
    }

    var item = await _echoesDatabase.itemDao.selectWithId(id: id);
    if (item != null) {
      _itemsCache[item.id] = item;
    }

    return item;
  }

  Future<String?> itemName({required id}) async {
    final rows = await _echoesDatabase.db.rawQuery('''
      SELECT $_currentLanguageCode, source
      FROM ${_echoesDatabase.localisedStringDao.tableName}
      INNER JOIN ${_echoesDatabase.itemDao.tableName} ON ${_echoesDatabase.localisedStringDao.tableName}.id = ${_echoesDatabase.itemDao.tableName}.nameKey
      WHERE ${_echoesDatabase.itemDao.tableName}.id = $id
      ''');

    if (rows.isNotEmpty) {
      return rows.first[_currentLanguageCode] as FutureOr<String?>? ??
          rows.first['source'] as FutureOr<String?>;
    }
    return null;
  }

  Future<List<Item>> itemsWithIds({required List<int> ids}) async =>
      (await _echoesDatabase.itemDao.selectWithIds(ids: ids)).toList();

  Future<Iterable<Item>> itemsFilteredOnName({required String filter}) async =>
      await _echoesDatabase.itemDao
          .filterOnName(filter: filter, languageCode: _currentLanguageCode);

  Future<Iterable<Item>> itemsFilteredOnNameAndMarketGroup(
      {required String filter, required int marketGroupId}) async {
    if (marketGroupId == MarketGroupFilters.drones.marketGroupId) {
      return itemsFilteredOnNameAndCategory(
        filter: filter,
        category: EveEchoesCategory.drones,
      );
    } else {
      return await _echoesDatabase.itemDao.filterOnNameAndMarketGroup(
        filter: filter,
        languageCode: _currentLanguageCode,
        marketGroupId: marketGroupId,
      );
    }
  }

  Future<Iterable<Item>> itemsFilteredOnNameAndCategory(
          {required String filter,
          required EveEchoesCategory category}) async =>
      await _echoesDatabase.itemDao.filterOnNameAndCategory(
        filter: filter,
        languageCode: _currentLanguageCode,
        categoryId: category.categoryId,
      );

  Future<Iterable<Item>> itemsForMarketGroup(
          {required int marketGroupId}) async =>
      await _echoesDatabase.itemDao
          .select(whereClause: 'WHERE marketGroupId = $marketGroupId');

  Future<Iterable<ItemNanocoreAffix>> nanocoreAffixesForSecondClass(
      {required int classId}) async =>
      await _echoesDatabase.itemNanocoreAffixDao
          .select(whereClause: 'WHERE attrSecondClass = $classId');

  Future<Implant?> implantWithId({required int id}) async {
    var implant = await _echoesDatabase.implantDao.selectWithId(id: id);

    return implant;
  }

  Future<int?> shipModeForShip({required int shipId}) async {
    final rows = await _echoesDatabase.db.rawQuery('''
      SELECT modeId
      FROM ${_echoesDatabase.shipModesDao.tableName}
      WHERE shipId = $shipId AND modeId != 11900000000
      ''');
    return rows
        .map((row) => row['modeId'] ?? -1)
        .where((e) => e != -1)
        .firstOrNull as FutureOr<int?>;
  }

  Future<Iterable<Item>> itemsForGroup(
          {required int groupId, bool includeUnpublished = false}) async =>
      (await _echoesDatabase.itemDao.selectWithGroup(groupId: groupId))
          .where((skill) => includeUnpublished ? true : skill.published == 1);

  Future<NpcEquipment?> npcEquipmentWithId({required int id}) async =>
      await _echoesDatabase.npcEquipmentDao.selectWithId(id: id);

  ///
  ///
  Future<Map<int, Iterable<ItemModifier>>> getModifiersForSkillIds(
      Iterable<int> ids) async {
    return await _echoesDatabase.db.rawQuery('''
      SELECT items.id as itemId, item_modifiers.*
      FROM items
      JOIN item_modifiers ON item_modifiers.code BETWEEN printf(items.mainCalCode, 1) AND printf(items.mainCalCode, 5)  
      WHERE items.id IN (${ids.join(', ')})
    ''').then(
      (rows) => groupBy(rows, (dynamic row) => row['itemId'] as int? ?? 0).map(
        (itemId, row) => MapEntry(
            itemId,
            row.map((json) =>
                _echoesDatabase.itemModifierDao.convertRowToItem(json))),
      ),
    );
  }

  ///
  ///
  ///
  Future<Iterable<ItemModifier>> getModifiersForItemId({int? id}) async {
    return await _echoesDatabase.db.rawQuery('''
      SELECT items.id as itemId, item_modifiers.*
      FROM items
      JOIN item_modifiers ON items.mainCalCode = item_modifiers.code OR items.onlineCalCode = item_modifiers.code OR items.activeCalCode = item_modifiers.code 
      WHERE items.id = $id
    ''').then((rows) => rows.map((json) => _echoesDatabase.itemModifierDao.convertRowToItem(json)));
  }

  Future<Iterable<ItemModifier>> getPassiveModifiersForModifier({required String code}) async {
    final calCode = getPassiveCalCode(code);
    return await _echoesDatabase.db.rawQuery('''
      SELECT item_modifiers.*
      FROM item_modifiers
      WHERE item_modifiers.code = '$calCode'
    ''').then((rows) => rows.map((json) => _echoesDatabase.itemModifierDao.convertRowToItem(json)));
  }

  ///
  ///
  Future<Iterable<Attribute>> getBaseAttributesForItemId({int? id}) async {
    return await _echoesDatabase.db.rawQuery('''
      SELECT items.id as itemId, item_attributes.value as baseValue, attributes.*
      FROM item_attributes 
      LEFT JOIN attributes ON item_attributes.attributeId = attributes.id
      LEFT JOIN items ON item_attributes.itemId = items.id
      WHERE items.id = $id
    ''').then((rows) => rows.map((json) => _echoesDatabase.attributeDao.convertRowToItem(json)));
  }

  ///
  ///
  Future<Map<int, Iterable<Attribute>>> getBaseAttributesForItemIds(
      Iterable<int> ids) async {
    return await _echoesDatabase.db.rawQuery('''
      SELECT items.id as itemId, item_attributes.value as baseValue, attributes.*
      FROM item_attributes 
      LEFT JOIN attributes ON item_attributes.attributeId = attributes.id
      LEFT JOIN items ON item_attributes.itemId = items.id
      WHERE items.id IN (${ids.join(', ')})
    ''').then(
      (rows) => groupBy(rows, (dynamic row) => row['itemId'] as int? ?? 0).map(
        (itemId, row) => MapEntry(
            itemId,
            row.map(
                (json) => _echoesDatabase.attributeDao.convertRowToItem(json))),
      ),
    );
  }

  Future<double?> attributeValue({required int id, required int itemId}) async {
    // HACK: This is stupid, and I don't understand why this isn't in the data
    // but lets be honest - NetEase hates me and wants me to cry T-T
    if (id == EveEchoesAttribute.nanocoreSlotCount.attributeId) {
      var attributeDefinition = await attributeWithId(
          id: EveEchoesAttribute.nanocoreSlotCount.attributeId);

      return attributeDefinition?.defaultValue;
    }

    var value = await _echoesDatabase.itemAttributeDao
        .valueForItem(itemId: itemId, attributeId: id);

    return value;
  }

  Future<Iterable<int>> getExcludeFusionRigs() async {
    return await _echoesDatabase.db.rawQuery('''
      SELECT itemId FROM item_attributes
      WHERE attributeId = 193 AND value <> 0.0;
     ''').then(
        (rows) => rows.map((r) => r["itemId"] as int? ?? 0).where((id) => id != 0)
    );
  }

  Future<Iterable<ItemAttributeValue>> attributeIdsForItem(
          {required Item item}) async =>
      await _echoesDatabase.itemAttributeDao.selectForItem(itemId: item.id);

  Future<Iterable<ItemEffect>> itemEffects({required Item forItem}) async =>
      await _echoesDatabase.itemEffectDao.selectForItem(itemId: forItem.id);

  Future<Effect?> getDefaultEffect({required int id}) async {
    var effectId =
        await _echoesDatabase.itemEffectDao.getDefaultEffectId(itemId: id);
    return await _echoesDatabase.effectDao.selectWithId(id: effectId);
  }

  Future<ItemNanocore?> nanocoreWithId({required int id}) {
    // Could combine and roll as one class later?
    return _echoesDatabase.itemNanocoreDao.selectForItem(itemId: id);
  }
}
