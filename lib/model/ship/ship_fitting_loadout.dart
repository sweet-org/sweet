import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:sweet/model/fitting/fitting_module.dart';
import 'package:sweet/model/ship/ship_fitting_slot_module.dart';
import 'package:sweet/model/ship/slot_type.dart';
import 'package:uuid/uuid.dart';

import 'ship_fitting_slot.dart';
import '../../database/entities/npc_equipment.dart';
import 'ship_loadout_definition.dart';

part 'ship_fitting_loadout.g.dart';

List<ShipFittingLoadout> loadoutsFromJson(String str) =>
    List<ShipFittingLoadout>.from(
        jsonDecode(str).map((x) => ShipFittingLoadout.fromJson(x)));

@JsonSerializable()
class ShipFittingLoadout extends ChangeNotifier with EquatableMixin {
  final String _id;

  static String get defaultName => 'Unnamed Fitting';
  String get id => _id;
  final int shipItemId;
  String _name;
  String get name => _name;
  void setName(String newName) {
    _name = newName;
    notifyListeners();
  }

  final ShipFittingSlot highSlots;
  final ShipFittingSlot midSlots;
  final ShipFittingSlot lowSlots;
  final ShipFittingSlot combatRigSlots;
  final ShipFittingSlot engineeringRigSlots;
  final ShipFittingSlot droneBay;
  final ShipFittingSlot nanocoreSlots;
  final ShipFittingSlot lightFrigatesSlots;
  final ShipFittingSlot lightDestroyersSlots;
  final ShipFittingSlot hangarRigSlots;

  ShipFittingLoadout({
    String? id,
    required String name,
    required this.shipItemId,
    required this.highSlots,
    required this.midSlots,
    required this.lowSlots,
    required this.combatRigSlots,
    required this.engineeringRigSlots,
    required this.droneBay,
    required this.nanocoreSlots,
    required this.lightFrigatesSlots,
    required this.lightDestroyersSlots,
    required this.hangarRigSlots,
  })  : _id = id ?? Uuid().v1(),
        _name = name;

  factory ShipFittingLoadout.fromJson(Map<String, dynamic> json) {
    json['lightFrigatesSlots'] =
        json['lightFrigatesSlots'] ?? <String, dynamic>{};
    json['lightDestroyersSlots'] =
        json['lightDestroyersSlots'] ?? <String, dynamic>{};
    json['hangarRigSlots'] = json['hangarRigSlots'] ?? <String, dynamic>{};
    return _$ShipFittingLoadoutFromJson(json);
  }

  Map<String, dynamic> toJson() => _$ShipFittingLoadoutToJson(this);

  factory ShipFittingLoadout.fromShip(
          int shipId, ShipLoadoutDefinition loadoutDefinition) =>
      ShipFittingLoadout(
        name: ShipFittingLoadout.defaultName,
        shipItemId: shipId,
        highSlots: ShipFittingSlot(
          maxSlots: loadoutDefinition.numHighSlots,
        ),
        midSlots: ShipFittingSlot(
          maxSlots: loadoutDefinition.numMidSlots,
        ),
        lowSlots: ShipFittingSlot(
          maxSlots: loadoutDefinition.numLowSlots,
        ),
        engineeringRigSlots: ShipFittingSlot(
          maxSlots: loadoutDefinition.numEngineeringRigSlots,
        ),
        combatRigSlots: ShipFittingSlot(
          maxSlots: loadoutDefinition.numCombatRigSlots,
        ),
        droneBay: ShipFittingSlot(
          maxSlots: loadoutDefinition.numDroneSlots,
        ),
        nanocoreSlots: ShipFittingSlot(
          maxSlots: loadoutDefinition.numNanocoreSlots,
        ),
        lightFrigatesSlots: ShipFittingSlot(
          maxSlots: loadoutDefinition.numLightFrigatesSlots,
        ),
        lightDestroyersSlots: ShipFittingSlot(
          maxSlots: loadoutDefinition.numLightDestroyersSlots,
        ),
        hangarRigSlots: ShipFittingSlot(
          maxSlots: loadoutDefinition.numHangarRigSlots,
        ),
      );

  factory ShipFittingLoadout.fromDrone({
    required int droneId,
    required NpcEquipment loadout,
    required ShipLoadoutDefinition loadoutDefinition,
  }) =>
      ShipFittingLoadout(
        name: ShipFittingLoadout.defaultName,
        shipItemId: droneId,
        highSlots: ShipFittingSlot(
          maxSlots: loadoutDefinition.numHighSlots,
          modules: loadout.highslot
              .map((e) => ShipFittingSlotModule(moduleId: e))
              .toList(),
        ),
        midSlots: ShipFittingSlot(
          maxSlots: loadoutDefinition.numMidSlots,
          modules: loadout.medslot
              .map((e) => ShipFittingSlotModule(moduleId: e))
              .toList(),
        ),
        lowSlots: ShipFittingSlot(
          maxSlots: loadoutDefinition.numLowSlots,
          modules: loadout.lowslot
              .map((e) => ShipFittingSlotModule(moduleId: e))
              .toList(),
        ),
        engineeringRigSlots:
            ShipFittingSlot(maxSlots: loadoutDefinition.numEngineeringRigSlots),
        combatRigSlots:
            ShipFittingSlot(maxSlots: loadoutDefinition.numCombatRigSlots),
        droneBay: ShipFittingSlot(maxSlots: loadoutDefinition.numDroneSlots),
        nanocoreSlots:
            ShipFittingSlot(maxSlots: loadoutDefinition.numNanocoreSlots),
        // FUTURENOTE: This might need to be looked at, though future fitting model ideas
        // might also make this moot
        lightFrigatesSlots: ShipFittingSlot(
          maxSlots: 0,
        ),
        lightDestroyersSlots: ShipFittingSlot(
          maxSlots: 0,
        ),
        hangarRigSlots: ShipFittingSlot(
          maxSlots: 0,
        ),
      );

  List<ShipFittingSlot> get allSlots => [
        highSlots,
        midSlots,
        lowSlots,
        combatRigSlots,
        engineeringRigSlots,
        droneBay,
        nanocoreSlots,
        lightFrigatesSlots,
        lightDestroyersSlots,
        hangarRigSlots,
      ];

  List<ShipFittingSlotModule> get allFittedModules {
    return allSlots
        .expand((e) => e.modules)
        .where((e) => e != ShipFittingSlotModule.empty)
        .toList();
  }

  List<int> get allFittedItemIds {
    return allFittedModules.map((e) => e.moduleId).where((e) => e > 0).toList();
  }

  factory ShipFittingLoadout.fromQrCodeData(String qrCodeData) {
    var data = base64.decode(qrCodeData);
    var decompressed = BZip2Decoder().decodeBytes(data);
    var json = utf8.decode(decompressed);
    return ShipFittingLoadout.fromJson(jsonDecode(json));
  }

  String generateQrCodeData() {
    var jsonData = utf8.encode(jsonEncode(this));
    var compressed = BZip2Encoder().encode(jsonData);
    return base64.encode(compressed);
  }

  @override
  List<Object?> get props => [
        name,
        shipItemId,
        highSlots,
        midSlots,
        lowSlots,
        combatRigSlots,
        engineeringRigSlots,
        droneBay,
        lightFrigatesSlots,
        lightDestroyersSlots,
        hangarRigSlots,
      ];

  void fitItem(FittingModule module) {
    var fittedModule = module.isValid
        ? ShipFittingSlotModule(
            moduleId: module.itemId,
            metadata: module.metadata,
            state: module.state,
          )
        : ShipFittingSlotModule.empty;

    switch (module.slot) {
      case SlotType.high:
        highSlots.modules[module.index] = fittedModule;
        break;
      case SlotType.mid:
        midSlots.modules[module.index] = fittedModule;
        break;
      case SlotType.low:
        lowSlots.modules[module.index] = fittedModule;
        break;
      case SlotType.combatRig:
        combatRigSlots.modules[module.index] = fittedModule;
        break;
      case SlotType.engineeringRig:
        engineeringRigSlots.modules[module.index] = fittedModule;
        break;
      case SlotType.drone:
        droneBay.modules[module.index] = fittedModule;
        break;
      case SlotType.nanocore:
        nanocoreSlots.modules[module.index] = fittedModule;
        break;
      case SlotType.lightFFSlot:
        lightFrigatesSlots.modules[module.index] = fittedModule;
        break;
      case SlotType.lightDDSlot:
        lightDestroyersSlots.modules[module.index] = fittedModule;
        break;
      case SlotType.hangarRigSlots:
        hangarRigSlots.modules[module.index] = fittedModule;
        break;
    }
  }

  ShipFittingLoadout copyWithName(String fittingName) => ShipFittingLoadout(
        name: fittingName,
        shipItemId: shipItemId,
        highSlots: highSlots.copy(),
        midSlots: midSlots.copy(),
        lowSlots: lowSlots.copy(),
        combatRigSlots: combatRigSlots.copy(),
        engineeringRigSlots: engineeringRigSlots.copy(),
        droneBay: droneBay.copy(),
        nanocoreSlots: nanocoreSlots.copy(),
        lightFrigatesSlots: lightFrigatesSlots.copy(),
        lightDestroyersSlots: lightDestroyersSlots.copy(),
        hangarRigSlots: hangarRigSlots.copy(),
      );

  void updateSlotDefinition(ShipLoadoutDefinition definition) {
    // TODO: THIS IS WHAT I NEED TO UPDATE
    // THANKS PAST DAN!
    highSlots.updateSlotCount(maxSlots: definition.numHighSlots);
    midSlots.updateSlotCount(maxSlots: definition.numMidSlots);
    lowSlots.updateSlotCount(maxSlots: definition.numLowSlots);
    combatRigSlots.updateSlotCount(maxSlots: definition.numCombatRigSlots);
    engineeringRigSlots.updateSlotCount(
        maxSlots: definition.numEngineeringRigSlots);
    droneBay.updateSlotCount(maxSlots: definition.numDroneSlots);
    nanocoreSlots.updateSlotCount(maxSlots: definition.numNanocoreSlots);
    lightFrigatesSlots.updateSlotCount(
      maxSlots: definition.numLightFrigatesSlots,
    );
    lightDestroyersSlots.updateSlotCount(
      maxSlots: definition.numLightDestroyersSlots,
    );
    hangarRigSlots.updateSlotCount(
      maxSlots: definition.numHangarRigSlots,
    );
  }

  // Future ideas:
  // Skill additions/overrides
}
