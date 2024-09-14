part of 'item_repository.dart';

extension ItemRepositoryFitting on ItemRepository {
  ///
  ///
  Future<FittingShip> ship({required int id}) async {
    final item = await itemWithId(id: id);
    final shipMode = await shipModeModule(shipId: id);
    final baseAttributes = await getBaseAttributesForItemId(id: id);
    final modifiers = await db.itemModifierDao.attributeBonusesForItemId(id);

    if (item == null) {
      throw Exception('Cannot find Ship with ID: $id');
    }

    return FittingShip(
      item: item,
      shipMode: shipMode,
      baseAttributes: baseAttributes.toList(),
      modifiers: modifiers.toList(),
    );
  }

  Future<FittingDrone> drone({
    required int id,
    required AttributeCalculatorService attributeCalculatorService,
  }) async {
    final item = await itemWithId(id: id);
    final baseAttributes = await getBaseAttributesForItemId(id: id);
    final modifiers = await db.itemModifierDao.attributeBonusesForItemId(id);
    final npcEquipmentId = baseAttributes.firstWhereOrNull((element) =>
        element.id == EveEchoesAttribute.entityEquipmentID.attributeId);
    final npcEquipment =
        await (npcEquipmentWithId(id: npcEquipmentId?.baseValue.toInt() ?? 0));

    if (npcEquipment == null) {
      throw Exception('Cannot find NPC Equipment of item $id');
    }

    if (item == null) {
      throw Exception('Cannot find Drone with ID: $id');
    }

    final loadoutDefinition = await getShipLoadoutDefinition(id);

    final loadout = ShipFittingLoadout.fromDrone(
      droneId: item.id,
      loadout: npcEquipment,
      loadoutDefinition: loadoutDefinition,
    );

    final droneShip = FittingShip(
      item: item,
      baseAttributes: baseAttributes.toList(),
      modifiers: modifiers.toList(),
    );

    return FittingDrone(
      item: item,
      baseAttributes: baseAttributes.toList(),
      modifiers: modifiers.toList(),
      fitting: await FittingSimulator.fromDrone(
        droneShip,
        loadout: loadout,
        itemRepository: this,
        attributeCalculatorService: attributeCalculatorService,
      ),
    );
  }

  ///
  ///
  Future<FittingModule?> shipModeModule({required int shipId}) async {
    final modeId = await shipModeForShip(shipId: shipId);

    return modeId == null
        ? null
        : module(id: modeId, initialState: ModuleState.inactive);
  }

  ///
  ///
  Future<FittingItem> _item({
    required int id,
  }) async {
    final item = await itemWithId(id: id);
    final baseAttributes = await getBaseAttributesForItemId(id: id);
    final modifiers = await getModifiersForItemId(id: id);

    if (item == null) {
      throw Exception('Cannot find item with ID: $id');
    }

    return FittingItem(
      item: item,
      baseAttributes: baseAttributes.toList(),
      modifiers: modifiers.toList(),
    );
  }

  Future<FittingModule> module({
    required int id,
    ModuleState initialState = ModuleState.active,
    Map<String, dynamic> metadata = const {},
  }) async {
    final item = await itemWithId(id: id);
    final baseAttributes = await getBaseAttributesForItemId(id: id);
    final modifiers = await getModifiersForItemId(id: id);

    if (item == null) {
      throw Exception('Cannot find Module with ID: $id');
    }

    if (kRigIntegrators.map((e) => e.groupId).contains(item.groupId)) {
      return rigIntegrator(id: id, metadata: metadata);
    }

    return FittingModule(
      item: item,
      baseAttributes: baseAttributes.toList(),
      modifiers: modifiers.toList(),
      state: initialState,
    );
  }

  Future<FittingImplantModule> implantModule({
    required int id,
    ModuleState initialState = ModuleState.active,
  }) async {
    final item = await itemWithId(id: id);
    final baseAttributes = await getBaseAttributesForItemId(id: id);
    final modifiers = await getModifiersForItemId(id: id);

    if (item == null) {
      throw Exception('Cannot find Module with ID: $id');
    }

    return FittingImplantModule(
      item: item,
      level: -1,
      slot: ImplantSlotType.common,
      baseAttributes: baseAttributes.toList(),
      modifiers: modifiers.toList(),
      state: initialState,
    );
  }

  Future<FittingModule> rig({
    required int id,
    Map<String, dynamic> metadata = const {},
  }) async {
    final item = await itemWithId(id: id);

    if (item == null) {
      throw Exception('Cannot find Module with ID: $id');
    }

    return item.isRigIntegrator
        ? rigIntegrator(
            id: id,
            metadata: metadata,
          )
        : module(id: id, metadata: metadata);
  }

  Future<FittingRigIntegrator> rigIntegrator({
    required int id,
    Map<String, dynamic> metadata = const {},
  }) async {
    final item = await itemWithId(id: id);
    final baseAttributes = await getBaseAttributesForItemId(id: id);
    final modifiers = await getModifiersForItemId(id: id);

    if (item == null) {
      throw Exception('Cannot find Module with ID: $id');
    }

    final rigIds = List<int>.from(
      metadata[FittingRigIntegrator.kSelectedRigItemIdsKey] ?? [],
    );
    final rigs = await Future.wait(
      rigIds.where((id) => id != 0).map((rigId) => module(id: rigId)),
    );

    return FittingRigIntegrator(
      baseItem: item,
      baseAttributes: baseAttributes.toList(),
      modifiers: modifiers.toList(),
      selectedRigs: rigs,
    );
  }

  Future<FittingNanocore> nanocore({
    required int id,
    Map<String, dynamic> metadata = const {},
  }) async {
    final item = await itemWithId(id: id);
    final nanocoreDetails = await nanocoreWithId(id: id);
    ItemNanocore? purpleCore;

    if (item == null || nanocoreDetails == null) {
      throw Exception('Cannot find Nanocore $id');
    }
    if (nanocoreDetails.isGold) {
      purpleCore = await nanocoreWithId(id: nanocoreDetails.otherItemId);
      if (purpleCore == null) {
        throw Exception('Cannot find Purple Nanocore '
            '${nanocoreDetails.otherItemId} for nanocore $id');
      }
    } else {
      purpleCore = nanocoreDetails;
    }

    final modifierIds = <int>{
      ...nanocoreDetails.selectableModifierItems,
      ...purpleCore.trainableModifierItems.expand((e) => e),
    };

    final modifiers = await Future.wait(
      modifierIds.map((id) => _item(id: id)),
    );

    final selectableModifiers = modifiers
        .where(
          (e) => nanocoreDetails.selectableModifierItems.contains(e.itemId),
        )
        .map(
          (e) => e,
        )
        .toList();

    final trainableableModifiers = purpleCore.trainableModifierItems
        .map(
          (level) => level
              .map(
                (id) =>
                    modifiers.firstWhereOrNull((e) => e.itemId == id) ??
                    FittingItem.empty,
              )
              .toList(),
        )
        .toList();

    final affixFutures =
        (metadata[FittingNanocore.kAffixesKey] as List<dynamic>?)
            ?.cast<int?>()
            .map((affixId) => affixId == null
                ? Future<FittingNanocoreAffix?>.value(null)
                : nanocoreAffixWithId(itemId: affixId));
    final affixes =
        affixFutures == null ? null : await Future.wait(affixFutures);
    final passiveAffixFutures =
        (metadata[FittingNanocore.kAffixesPassiveKey] as List<dynamic>?)
            ?.cast<int?>()
            .map((affixId) => affixId == null
                ? Future<FittingNanocoreAffix?>.value(null)
                : nanocoreAffixWithId(itemId: affixId));
    final passiveAffixes = passiveAffixFutures == null
        ? null
        : await Future.wait(passiveAffixFutures);

    return FittingNanocore.fromItems(
      baseItem: item,
      isGolden: nanocoreDetails.isGold,
      mainAttributes: selectableModifiers,
      trainableAttributes: trainableableModifiers,
      affixes: affixes,
      passiveAffixes: passiveAffixes,
      metadata: metadata,
    );
  }

  Future<FittingNanocoreAffixItem> _nanocoreAffixItem({
    required ItemNanocoreAffix affix,
  }) async {
    affix.item ??= await itemWithId(id: affix.attrId);
    final baseAttributes = await getBaseAttributesForItemId(id: affix.attrId);
    final modifiers = (await getModifiersForItemId(id: affix.attrId)).toList();
    final passiveMods =
        await getPassiveModifiersForModifier(code: modifiers[0].code);

    if (affix.item == null) {
      throw Exception('Cannot find affix item with ID: ${affix.attrId}');
    }

    return FittingNanocoreAffixItem(
      affix: affix,
      baseAttributes: baseAttributes.toList(),
      modifiers: modifiers,
      passiveModifiers: passiveMods.toList(),
    );
  }

  Future<FittingNanocoreAffix> nanocoreAffix(
      {required ItemNanocoreAffix affix}) async {
    final levels = <int, ItemNanocoreAffix>{};
    levels[affix.attrLevel] = affix;
    if (affix.children != null) {
      for (var a in affix.children!) {
        levels[a.attrLevel] = a;
      }
    }
    var futures = levels.values.map((e) => _nanocoreAffixItem(affix: e));
    final res = await Future.wait(futures);
    final items = Map<int, FittingNanocoreAffixItem>.fromEntries(
        res.map((e) => MapEntry(e.affix.attrLevel, e)));

    return FittingNanocoreAffix(items);
  }

  Future<FittingNanocoreAffix> nanocoreAffixWithId(
      {required int itemId}) async {
    var affix = goldAttrSecondClassMap.values
        .map((e) => e.items ?? [])
        .expand((e) => e)
        .firstWhere((e) =>
            e.attrId == itemId ||
            (e.children?.any((e) => e.attrId == itemId) ?? false));
    final itemAffix = await nanocoreAffix(affix: affix);
    final level = affix.attrId == itemId
        ? 0
        : affix.children!.firstWhere((e) => e.attrId == itemId).attrLevel;
    itemAffix.selectLevel(level);

    return itemAffix;
  }

  Future<FittingItem> loadFittingCharacter() => _item(id: 93000000000);

  Future<Iterable<FittingSkill>> fittingSkillsFromLearned(
    Iterable<LearnedSkill> skills,
  ) async {
    return skills.map(
      (e) => fittingSkills[e.skillId]!.copyWith(
        skillLevel: e.skillLevel,
      ),
    );
  }

  Future<Fitting> fittingDataFromLoadout({
    required ShipFittingLoadout loadout,
    required AttributeCalculatorService attributeCalculatorService,
  }) async {
    final fitting = Fitting(id: loadout.id, name: loadout.name);
    fitting.setFromLoadout(loadout);

    if (loadout.allFittedItemIds.isEmpty) {
      return fitting;
    }

    for (var slotIndex = 0; slotIndex < loadout.allSlots.length; slotIndex++) {
      final slot = SlotType.values[slotIndex];
      if (slot == SlotType.implantSlots) continue;
      final slotLoadout = loadout.allSlots[slotIndex];

      final slotModules = await _getModulesForSlot(
        slot,
        slotModules: slotLoadout.modules,
        attributeCalculatorService: attributeCalculatorService,
      );

      slotModules.forEachIndexed((moduleIndex, module) {
        fitting[slot]![moduleIndex] = module.copyWith(
          slot: slot,
          index: moduleIndex,
        );
      });
    }

    // Map into slots with the data
    return fitting;
  }

  Future<FittingImplantModule> _getImplantModulesForSlot(
      ImplantFittingSlotModule slotModule) {
    var mod = slotModule.moduleId == 0
        ? Future.value(FittingImplantModule.emptyCommon)
        : implantModule(
            id: slotModule.moduleId,
            initialState: slotModule.state,
          );
    return mod;
  }

  Future<List<FittingModule>> _getModulesForSlot(
    SlotType slot, {
    required List<ShipFittingSlotModule> slotModules,
    required AttributeCalculatorService attributeCalculatorService,
  }) {
    final Iterable<Future<FittingModule>> moduleFutures;
    switch (slot) {
      case SlotType.lightFFSlot:
      case SlotType.lightDDSlot:
      case SlotType.drone:
        moduleFutures = slotModules.map((slotModule) => slotModule.moduleId == 0
            ? Future.value(FittingModule.empty)
            : drone(
                id: slotModule.moduleId,
                attributeCalculatorService: attributeCalculatorService,
              ));
        break;
      case SlotType.nanocore:
        moduleFutures = slotModules.map(
          (slotModule) => slotModule.moduleId == 0
              ? Future.value(FittingModule.empty)
              : nanocore(
                  id: slotModule.moduleId,
                  metadata: slotModule.metadata,
                ),
        );
        break;
      case SlotType.combatRig:
      case SlotType.engineeringRig:
        moduleFutures = slotModules.map(
          (slotModule) => slotModule.moduleId == 0
              ? Future.value(FittingModule.empty)
              : rig(
                  id: slotModule.moduleId,
                  metadata: slotModule.metadata,
                ),
        );
        break;

      default:
        moduleFutures = slotModules.map(
          (slotModule) => slotModule.moduleId == 0
              ? Future.value(FittingModule.empty)
              : module(
                  id: slotModule.moduleId,
                  initialState: slotModule.state,
                ),
        );
    }

    return Future.wait(moduleFutures);
  }

  Future<ShipLoadoutDefinition> getShipLoadoutDefinition(int shipId) async {
    var ship = await (_echoesDatabase.itemDao.selectWithId(id: shipId));

    if (ship == null) {
      throw Exception('Cannot find Ship $shipId');
    }

    final numHighSlots = (await attributeValue(
          id: EveEchoesAttribute.highSlotCount.attributeId,
          itemId: shipId,
        ))
            ?.toInt() ??
        0;
    final numMidSlots = (await attributeValue(
          id: EveEchoesAttribute.midSlotCount.attributeId,
          itemId: shipId,
        ))
            ?.toInt() ??
        0;
    final numLowSlots = (await attributeValue(
          id: EveEchoesAttribute.lowSlotCount.attributeId,
          itemId: shipId,
        ))
            ?.toInt() ??
        0;
    final numCombatRigSlots = (await attributeValue(
          id: EveEchoesAttribute.combatRigSlotCount.attributeId,
          itemId: shipId,
        ))
            ?.toInt() ??
        0;
    final numEngineeringRigSlots = (await attributeValue(
          id: EveEchoesAttribute.engineeringRigSlotCount.attributeId,
          itemId: shipId,
        ))
            ?.toInt() ??
        0;
    final numDroneSlots = (await attributeValue(
          id: EveEchoesAttribute.droneBayCount.attributeId,
          itemId: shipId,
        ))
            ?.toInt() ??
        0;
    final numNanocoreSlots = (await attributeValue(
          id: EveEchoesAttribute.nanocoreSlotCount.attributeId,
          itemId: shipId,
        ))
            ?.toInt() ??
        0;
    final numLightFrigatesSlots = (await attributeValue(
          id: EveEchoesAttribute.lightFFSlot.attributeId,
          itemId: shipId,
        ))
            ?.toInt() ??
        0;
    final numLightDestroyersSlots = (await attributeValue(
          id: EveEchoesAttribute.lightDDSlot.attributeId,
          itemId: shipId,
        ))
            ?.toInt() ??
        0;
    // ToDo: Refactor hangar rig system
    var numHangarRigSlots = (await attributeValue(
          id: EveEchoesAttribute.hangarRigSlots.attributeId,
          itemId: shipId,
        ))
            ?.toInt() ??
        0;

    if (numHangarRigSlots == 0) {
      final shipDef = await this.ship(id: shipId);
      for (var mod in shipDef.modifiers) {
        if (mod.changeRange != "/Ship/") continue;
        if (hangarRigAttributes.contains(mod.attributeId)) {
          numHangarRigSlots += mod.attributeValue.toInt();
        }
      }
    }

    return ShipLoadoutDefinition(
      numHighSlots: numHighSlots,
      numMidSlots: numMidSlots,
      numLowSlots: numLowSlots,
      numCombatRigSlots: numCombatRigSlots,
      numEngineeringRigSlots: numEngineeringRigSlots,
      numDroneSlots: numDroneSlots,
      numNanocoreSlots: numNanocoreSlots,
      numLightFrigatesSlots: numLightFrigatesSlots,
      numLightDestroyersSlots: numLightDestroyersSlots,
      numHangarRigSlots: numHangarRigSlots,
    );
  }

  Future<ImplantLoadoutDefinition> getImplantLoadoutDefinition(
      int implantId) async {
    var implant =
        await (_echoesDatabase.implantDao.selectWithId(id: implantId));
    // print("item_repo_fitting $implantId");
    if (implant == null) {
      throw Exception('Cannot find Implant $implantId');
    }
    // print("item_repo_fitting: ${implant.implantFramework.length}");
    if (implant.implantType != 0) {
      throw Exception(
          'Item is not an implant (got type ${implant.implantType})');
    }
    /*
     * Type   Item
     * null   Neural Compilers, Blueprints
     * 0      Implant
     * 1      Fixed Branch choices (don't know why they have different levels)
     * 2      General Units
     */
    final slots = <int, ImplantSlotType>{};
    final restrictions = <int, List<int>>{};

    implant.implantFramework.forEach((slotId, value) {
      final int typeId = value[0];
      final int slotNum = int.parse(slotId);
      final slotType = ImplantSlotType.values
          .firstWhere((element) => element.typeId == typeId);
      slots[slotNum] = slotType;

      if (slotType == ImplantSlotType.common) return;

      // The remaining values in "value" contain the allowed items
      restrictions[slotNum] = value.sublist(1);
    });

    return ImplantLoadoutDefinition(slots: slots, restrictions: restrictions);
  }

  Future<List<NihilusSpaceModifier>> nSpaceModifiers() async {
    final modifiers = await db.itemModifierDao.select(
        whereClause:
            'WHERE typeCode = "$kNihilusCapAdjustmentModifierTypeCode"');
    final attributeIds = modifiers.map((e) => e.attributeId).toSet().toList();
    final attributes = await attributesWithIds(ids: attributeIds);
    final attributeMap = {for (var a in attributes) a.id: a};

    return modifiers
        .map(
          (e) => NihilusSpaceModifier(
              attribute: attributeMap[e.attributeId]!,
              code: e.code,
              typeCode: e.typeCode,
              changeType: e.changeType,
              attributeOnly: e.attributeOnly,
              changeRange: e.changeRange,
              changeRangeModuleNameId: e.changeRangeModuleNameId,
              attributeId: e.attributeId,
              attributeValue: e.attributeValue),
        )
        .toList();
  }
}
