part of 'item_repository.dart';


extension ItemRepositoryImplant on ItemRepository {
  Future<ImplantFitting> implantDataFromLoadout({
    required ImplantFittingLoadout loadout,
  }) async {
    final fitting = ImplantFitting(id: loadout.id, name: loadout.name);
    fitting.setFromLoadout(loadout);

    // if (loadout.allFittedItemIds.isEmpty) {
    //   return fitting;
    // }

    loadout.modules.forEach((slotId, slotModule) async {
      final module = await _getImplantModulesForSlot(slotModule);
      fitting[slotId] = module.copyWith(slot: slotModule.type, level: slotId);
    });

    return fitting;
  }
}