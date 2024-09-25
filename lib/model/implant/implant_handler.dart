import 'package:flutter/foundation.dart';
import 'package:sweet/model/fitting/fitting_implant.dart';
import 'package:sweet/model/fitting/fitting_implant_module.dart';
import 'package:sweet/model/fitting/fitting_item.dart';
import 'package:sweet/model/implant/implant_fitting_loadout.dart';
import 'package:sweet/model/implant/implant_loadout_definition.dart';
import 'package:sweet/model/implant/slot_type.dart';
import 'package:sweet/model/ship/module_state.dart';
import 'package:sweet/repository/implant_fitting_loadout_repository.dart';

import '../../repository/item_repository.dart';

class ImplantHandler extends ChangeNotifier {
  final ImplantFitting fitting;
  final FittingItem implant;
  final ImplantFittingLoadout loadout;
  final Map<int, List<int>> _restrictions;
  final ImplantSlotType _type;

  int get slotCount => fitting.allModules.length;

  int get trainedLevel => fitting.trainedLevel;

  bool get isPassive => _type == ImplantSlotType.slave;

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
    required this.fitting,
    required ImplantSlotType type,
    required Map<int, List<int>> restrictions,
  })  : _restrictions = restrictions,
        _type = type;

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
          isPassive: definition.implantType == ImplantSlotType.slave,
        ),
        restrictions: definition.restrictions,
        type: definition.implantType,
      );

  static Future<ImplantHandler?> fromImplantId(
      {required String? implantLoadoutId,
      required ImplantFittingLoadoutRepository implantRepository,
      required ItemRepository itemRepository}) async {
    if (implantLoadoutId == null) return null;
    final loadout = implantRepository.getLoadout(implantLoadoutId);
    if (loadout == null) return null;
    final item = await itemRepository.implantModule(id: loadout.implantItemId);
    final definition =
        await itemRepository.getImplantLoadoutDefinition(loadout.implantItemId);

    return await fromImplantLoadout(
      implant: item,
      itemRepository: itemRepository,
      definition: definition,
      loadout: loadout,
    );
  }

  String get name => loadout.name;

  void setName(String newName) {
    loadout.setName(newName);
    notifyListeners();
  }

  void setLevel(int newLevel) {
    fitting.trainedLevel = newLevel;
    loadout.setLevel(newLevel);
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

    var fittedModule = (module)
        .copyWith(level: slotId, slot: currentModule.slot, state: state);

    fitting[slotId] = fittedModule;

    loadout.fitItem(fitting[slotId]!, slotId);

    if (notify) {
      notifyListeners();
    }

    return true;
  }
}
