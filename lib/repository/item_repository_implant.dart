part of 'item_repository.dart';


extension ItemRepositoryImplant on ItemRepository {
  Future<ImplantFitting> implantDataFromLoadout({
    required ImplantFittingLoadout loadout,
  }) async {
    final id = loadout.implantItemId;
    final item = await itemWithId(id: id);
    final baseAttributes = await getBaseAttributesForItemId(id: id);
    final modifiers = await getModifiersForItemId(id: id);

    if (item == null) {
      throw Exception('Cannot find Implant with ID: ${loadout.implantItemId}');
    }
    // final implant = await implantModule(id: loadout.implantItemId);

    final fitting = ImplantFitting(
        id: loadout.id,
        name: loadout.name,
        trainedLevel: loadout.level,
        item: item,
        baseAttributes: baseAttributes.toList(),
        modifiers: modifiers.toList()
    );
    fitting.setFromLoadout(loadout);

    await Future.forEach(loadout.modules.entries, (MapEntry<int, ImplantFittingSlotModule> entry) async {
      var slotId = entry.key;
      var slotModule = entry.value;
      final module = await _getImplantModulesForSlot(slotModule);
      fitting[slotId] = module.copyWith(slot: slotModule.type, level: slotId);
    });
    return fitting;
  }

  List<Attribute> getExtraAttrs() {
    
    return [];
  }
}