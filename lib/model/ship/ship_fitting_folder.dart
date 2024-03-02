
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:sweet/model/ship/fitting_list_element.dart';
import 'package:sweet/model/ship/ship_fitting_loadout.dart';
import 'package:uuid/uuid.dart';

part 'ship_fitting_folder.g.dart';

@JsonSerializable()
class ShipFittingFolder extends ChangeNotifier with FittingListElement, EquatableMixin {
  final String _id;
  final String _type = 'FOLDER';
  final List<FittingListElement> _contents;

  static String get defaultName => 'Unnamed Folder';

  String get id => _id;
  String _name;
  String get name => _name;
  String get type => _type;

  List<FittingListElement> get contents => _contents;

  @override
  String getId() => _id;

  @override
  String getName() => _name;

  void setName(String newName) {
    _name = newName;
    notifyListeners();
  }

  FittingListElement? getElement(String elementId) {
    FittingListElement? target = _contents.firstWhereOrNull((c) => c.getId() == elementId);
    if (target != null) {
      return target;
    }
    ShipFittingFolder? folder = _contents.whereType<ShipFittingFolder>().firstWhereOrNull((f) => f.hasElement(elementId));
    if (folder != null) {
      return folder.getElement(elementId);
    }
    return null;
  }

  List<ShipFittingFolder> getAllSubFolders() {
    List<ShipFittingFolder> res = [];
    for (ShipFittingFolder folder in _contents.whereType<ShipFittingFolder>()) {
      res.add(folder);
      res.addAll(folder.getAllSubFolders());
    }
    return res;
  }

  bool hasElement(String elementId) => getElement(elementId) != null;

  void deleteElement(String elementId) {
    _contents.removeWhere((loadout) => loadout.getId() == elementId);
    //Delete also recursively
    _contents.whereType<ShipFittingFolder>().forEach((folder) => folder.deleteElement(elementId));
  }

  ShipFittingFolder? findFolderOf(String elementId) {
    ShipFittingFolder? folder = _contents.whereType<ShipFittingFolder>().firstWhereOrNull((f) => f.hasElement(elementId));
    if (folder == null) {
      return null;
    }
    // Check if the element is in this current folder or in a subfolder
    ShipFittingFolder? subFolder = folder.findFolderOf(elementId);
    return subFolder ?? folder;
  }

  int getSize() {
    int counter = 0;
    counter += _contents.whereType<ShipFittingLoadout>().length;
    _contents.whereType<ShipFittingFolder>().forEach((element) {
      counter += element.getSize();
    });
    return counter;
  }

  ShipFittingFolder({
    String? id,
    required String name,
    List<FittingListElement>? contents,
    String? type  // Only attributes included in the constructor are serialized
  })  : _id = id ?? Uuid().v1(),
        _name = name,
        _contents = contents ?? [];

  factory ShipFittingFolder.fromJson(Map<String, dynamic> json) {
    return _$ShipFittingFolderFromJson(json);
  }

  Map<String, dynamic> toJson() => _$ShipFittingFolderToJson(this);

  @override
  List<Object?> get props => [
    name
  ];
}