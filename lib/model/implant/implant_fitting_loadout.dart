import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:sweet/model/implant/implant_loadout_definition.dart';
import 'package:sweet/model/implant/slot_type.dart';
import 'package:uuid/uuid.dart';

import 'package:sweet/model/implant/implant_fitting_slot_module.dart';
import 'package:sweet/model/fitting/fitting_implant_module.dart';

part 'implant_fitting_loadout.g.dart';

List<ImplantFittingLoadout> implantsFromJson(String str) =>
    List<ImplantFittingLoadout>.from(jsonDecode(str).map((x) {
        return ImplantFittingLoadout.fromJson(x);
    }));

@JsonSerializable()
class ImplantFittingLoadout extends ChangeNotifier with EquatableMixin {
  final String _id;
  final String _type = 'IMPLANT';

  static String get defaultName => 'Unnamed Implant';

  String get id => _id;
  final int implantItemId;
  String _name;
  int _level;

  String get name => _name;

  String get type => _type;

  int get level => _level;

  String getId() => _id;

  String getName() => _name;

  void setName(String newName) {
    _name = newName;
    notifyListeners();
  }

  void setLevel(int newLevel) {
    _level = newLevel;
    notifyListeners();
  }

  final Map<int, ImplantFittingSlotModule> modules;

  ImplantFittingLoadout({
    String? id,
    required String name,
    required this.implantItemId,
    required this.modules,
    int? level,
    String? type, // Only attributes included in the constructor are serialized
  })  : _id = id ?? Uuid().v1(),
        _name = name,
        _level = level ?? 1;

  factory ImplantFittingLoadout.fromJson(Map<String, dynamic> json) {
    return _$ImplantFittingLoadoutFromJson(json);
  }

  Map<String, dynamic> toJson() => _$ImplantFittingLoadoutToJson(this);

  factory ImplantFittingLoadout.fromDefinition(
          int implantId, ImplantLoadoutDefinition loadoutDefinition) =>
      ImplantFittingLoadout(
          name: ImplantFittingLoadout.defaultName,
          implantItemId: implantId,
          modules: loadoutDefinition.slots.map((key, value) => MapEntry(
              key, ImplantFittingSlotModule.getEmpty(value))
          )
      );

  // List<ImplantFittingSlotModule> get allSlots => List.of(modules.values);

  List<ImplantFittingSlotModule> get allFittedModules {
    return List.of(modules.values);
  }

  List<int> get allFittedItemIds {
    return allFittedModules.map((e) => e.moduleId).where((e) => e > 0).toList();
  }

  // ToDo: Add QR Code support
  /*factory ShipFittingLoadout.fromQrCodeData(String qrCodeData) {
    var data = base64.decode(qrCodeData);
    var decompressed = BZip2Decoder().decodeBytes(data);
    var json = utf8.decode(decompressed);
    return ShipFittingLoadout.fromJson(jsonDecode(json));
  }

  String generateQrCodeData() {
    var jsonData = utf8.encode(jsonEncode(this));
    var compressed = BZip2Encoder().encode(jsonData);
    return base64.encode(compressed);
  }*/

  @override
  List<Object?> get props => [name, implantItemId, modules];

  void fitItem(FittingImplantModule module, int slotId) {
    ImplantSlotType type = module.slot;
    var fittedModule = module.isValid
        ? ImplantFittingSlotModule(
            moduleId: module.itemId,
            type: type,
            state: module.state,
          )
        : ImplantFittingSlotModule.getEmpty(type);

    modules[slotId] = fittedModule;
  }

  ImplantFittingLoadout copyWithName(String fittingName) =>
      ImplantFittingLoadout(
        name: fittingName,
        implantItemId: implantItemId,
        modules: Map<int, ImplantFittingSlotModule>.from(
            modules.map((key, value) => MapEntry(key, value.copy()))),
      );
}
