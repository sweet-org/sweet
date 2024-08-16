import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sweet/model/implant/implant_fitting_loadout.dart';

class ImplantFittingLoadoutRepository {
  final String prefsKey = 'implantsJson';
  List<ImplantFittingLoadout> _implants = [];
  Iterable<ImplantFittingLoadout> get implants => _implants;

  Future<bool> loadImplants({List<ImplantFittingLoadout>? data}) async {
    if (data != null) {
      _implants = data;
    } else {
      var prefs = await SharedPreferences.getInstance();
      var json = prefs.getString(prefsKey);
      if (json != null && json.isNotEmpty) {
        _implants = implantsFromJson(json);
      }
    }

    return true;
  }

  Future<bool> saveImplants() async {
    var json = jsonEncode(_implants);
    var prefs = await SharedPreferences.getInstance();
    return prefs.setString(prefsKey, json);
  }

  Future<bool> addImplant(ImplantFittingLoadout implant) async {
    deleteLoadoutSync(implant.id);
    _implants.add(implant);
    return saveImplants();
  }

  Future<bool> deleteImplant({required String loadoutId}) async {
    deleteLoadoutSync(loadoutId);
    return saveImplants();
  }

  void deleteLoadoutSync(String loadoutId) {
    _implants.removeWhere((loadout) => loadout.getId() == loadoutId);
  }

  ImplantFittingLoadout? getLoadout(String id) {
    //Check if the loadout is in the root list (= not inside any folder)
    ImplantFittingLoadout? target = _implants.firstWhereOrNull((c) => c.getId() == id);
    if (target != null) {
      return target;
    }
    return null;
  }

  bool containsLoadout(ImplantFittingLoadout loadout) =>
      getLoadout(loadout.getId()) != null;
}