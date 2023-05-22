import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sweet/model/ship/ship_fitting_loadout.dart';

class ShipFittingLoadoutRepository {
  final String prefsKey = 'loadoutsJson';
  List<ShipFittingLoadout /*!*/ > _loadouts = [];
  Iterable<ShipFittingLoadout> get loadouts => _loadouts;

  Future<bool> loadLoadouts({List<ShipFittingLoadout>? data}) async {
    if (data != null) {
      _loadouts = data;
    } else {
      var prefs = await SharedPreferences.getInstance();
      var json = prefs.getString(prefsKey);
      if (json != null && json.isNotEmpty) {
        _loadouts = loadoutsFromJson(json);
      }
    }

    return true;
  }

  Future<bool> saveLoadouts() async {
    var json = jsonEncode(_loadouts);
    var prefs = await SharedPreferences.getInstance();
    return prefs.setString(prefsKey, json);
  }

  Future<bool> addLoadout(ShipFittingLoadout loadout) async {
    _loadouts.removeWhere((c) => c.id == loadout.id);
    _loadouts.add(loadout);
    return saveLoadouts();
  }

  Future<bool> deleteLoadout({required String loadoutId}) async {
    _loadouts.removeWhere((loadout) => loadout.id == loadoutId);
    return saveLoadouts();
  }

  ShipFittingLoadout? getLoadout(String id) {
    return _loadouts.firstWhereOrNull((c) => c.id == id);
  }

  bool containsLoadout(ShipFittingLoadout loadout) =>
      getLoadout(loadout.id) != null;

  Future<void> moveFitting({
    required ShipFittingLoadout fitting,
    required int newIndex,
  }) async {
    var index = _loadouts.indexWhere((e) => e.id == fitting.id);

    if (index >= 0) {
      print('Moving ${fitting.name} to $newIndex');

      _loadouts.removeAt(index);
      _loadouts.insert(newIndex, fitting);

      await saveLoadouts();
    }
  }
}
