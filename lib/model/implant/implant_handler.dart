
import 'package:flutter/foundation.dart';
import 'package:sweet/model/fitting/fitting_implant.dart';
import 'package:sweet/model/fitting/fitting_implant_module.dart';
import 'package:sweet/model/fitting/fitting_item.dart';
import 'package:sweet/model/implant/implant_fitting_loadout.dart';
import 'package:sweet/model/implant/implant_loadout_definition.dart';
import 'package:sweet/model/ship/module_state.dart';

import '../../repository/item_repository.dart';

class ImplantHandler extends ChangeNotifier {
  final ImplantFitting fitting;
  final FittingItem implant;
  final ImplantFittingLoadout loadout;
  final ItemRepository _itemRepository;
  final Map<int, List<int>> _restrictions;

  int get slotCount => fitting.allModules.length;

  FittingImplantModule? getModuleByIndex(int index) {
    return fitting.getModuleByIndex(index);
  }

  List<int>? getLimitationsByIndex(int index) {
    var slotId = fitting.getSlotIdByIndex(index);
    return _restrictions[slotId];
  }

  ImplantHandler._create({
    required ItemRepository itemRepository,
    required this.implant,
    required this.loadout,
    required ImplantFitting fitting,
    required Map<int, List<int>> restrictions,
  })  : fitting = fitting,
        _itemRepository = itemRepository,
        _restrictions = restrictions;

  static Future<ImplantHandler> fromImplantLoadout({
    required FittingItem implant,
    required ImplantFittingLoadout loadout,
    required ItemRepository itemRepository,
    required ImplantLoadoutDefinition definition,

  }) async =>
      ImplantHandler._create(
        itemRepository: itemRepository,
        implant: implant,
        loadout: loadout,
        fitting: await itemRepository.implantDataFromLoadout(
          loadout: loadout,
        ),
        restrictions: definition.restrictions
      );

  String get name => loadout.name;
  void setName(String newName) {
    loadout.setName(newName);
    notifyListeners();
  }

  bool fitItem(
      FittingImplantModule module, {
        required int slotIndex,
        bool notify = true,
        ModuleState state = ModuleState.active,
  }) {
    var slotId = fitting.getSlotIdByIndex(slotIndex);
    var currentModule = fitting[slotId]!;

    var fittedModule = (module).copyWith(
      level: slotId,
      slot: currentModule.slot,
      state: state
    );

    fitting[slotId] = fittedModule;

    loadout.fitItem(fitting[slotId]!, slotId);

    if (notify) {
       notifyListeners();
    }

    return true;
  }
}
