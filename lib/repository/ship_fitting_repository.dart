import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sweet/model/ship/fitting_list_element.dart';
import 'package:sweet/model/ship/ship_fitting_folder.dart';

import 'package:sweet/model/ship/ship_fitting_loadout.dart';

class ShipFittingLoadoutRepository {
  final String prefsKey = 'loadoutsJson';
  List<FittingListElement /*!*/ > _loadouts = [];
  Iterable<FittingListElement> get loadouts => _loadouts;

  Future<bool> loadLoadouts({List<FittingListElement>? data}) async {
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

  Future<bool> addLoadout(FittingListElement loadout) async {
    ShipFittingFolder? folder = findFolderOf(loadout.getId());
    deleteLoadoutSync(loadout.getId());
    if (folder == null) {
      //Item is new or was not in a folder
      _loadouts.add(loadout);
    } else {
      //Item was already in a folder, so put it back where it was
      folder.contents.add(loadout);
    }
    return saveLoadouts();
  }

  ShipFittingFolder? findFolderOf(String id) {
    ShipFittingFolder? folder = _loadouts.whereType<ShipFittingFolder>().firstWhereOrNull((f) => f.hasElement(id));
    if (folder == null) {
      return null;
    }
    // Check if the element is in this current folder or in a subfolder
    ShipFittingFolder? subFolder = folder.findFolderOf(id);
    return subFolder ?? folder;
  }

  List<ShipFittingFolder> getAllFolders() {
    List<ShipFittingFolder> res = [];
    for (ShipFittingFolder folder in _loadouts.whereType<ShipFittingFolder>()) {
      res.add(folder);
      res.addAll(folder.getAllSubFolders());
    }
    return res;
  }

  void deleteLoadoutSync(String loadoutId) {
    _loadouts.removeWhere((loadout) => loadout.getId() == loadoutId);
    //Also check in folders for loadout
    _loadouts.whereType<ShipFittingFolder>().forEach((folder) => folder.deleteElement(loadoutId));
  }

  Future<bool> deleteLoadout({required String loadoutId}) async {
    deleteLoadoutSync(loadoutId);
    return saveLoadouts();
  }

  FittingListElement? getLoadout(String id) {
    //Check if the loadout is in the root list (= not inside any folder)
    FittingListElement? target = _loadouts.firstWhereOrNull((c) => c.getId() == id);
    if (target != null) {
      return target;
    }
    //Search recursively in all folders for the element
    ShipFittingFolder? folder = _loadouts.whereType<ShipFittingFolder>().firstWhereOrNull((f) => f.hasElement(id));
    if (folder != null) {
      return folder.getElement(id);
    }
    return null;
  }

  bool containsLoadout(FittingListElement loadout) =>
      getLoadout(loadout.getId()) != null;

  Future<void> moveFitting({
    required FittingListElement element,
    required int newIndex,
  }) async {
    var index = _loadouts.indexWhere((e) => e.getId() == element.getId());

    if (index >= 0) {
      print('Moving ${element.getName()} to $newIndex');

      _loadouts.removeAt(index);
      _loadouts.insert(newIndex, element);

      await saveLoadouts();
    }
  }

  moveToFolder({required FittingListElement loadout, required String folderId}) async {
    ShipFittingFolder? folder;

    if (folderId == "") {
      //Move item out of current folder into root list
      deleteLoadoutSync(loadout.getId());
      _loadouts.add(loadout);
      await saveLoadouts();
      return;
    }

    for (final el in _loadouts) {
      if (el is! ShipFittingFolder) continue;
      if (el.id == folderId) {
        folder = el;
        break;
      }
    }
    if (folder == null) {
      print('Folder with id "$folderId" not found, can\'t move item ${loadout.getName()}');
      return;
    }

    if (_loadouts.contains(loadout)) {
      // Our item is currently not in a folder
      folder.contents.add(loadout);
      _loadouts.remove(loadout);
      print('Item ${loadout.getName()} moved to folder ${folder.name}');
    } else {
      // Our item is already in another folder (or the same)
      ShipFittingFolder? currentFolder;
      for (final el in _loadouts) {
        if (el is! ShipFittingFolder) continue;
        if (el.contents.contains(loadout)) {
          currentFolder = el;
          break;
        }
      }
      if (currentFolder == null) {
        print('Loadout ${loadout.getId()} was not found anywhere, can\'t move it');
        return;
      }
      folder.contents.add(loadout);
      currentFolder.contents.remove(loadout);
      print('Moved loadout ${loadout.getId()} to folder ${folder.getId()}');
    }
    await saveLoadouts();
  }
}
