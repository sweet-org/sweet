import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'npc_equipment.g.dart';

List<NpcEquipment> npcEquipmentFromJson(String str) => List<NpcEquipment>.from(
    json.decode(str).map((x) => NpcEquipment.fromJson(x)));

String npcEquipmentToJson(List<NpcEquipment> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

@JsonSerializable(includeIfNull: true)
class NpcEquipment {
  NpcEquipment({
    required this.id,
    required this.highslot,
    required this.medslot,
    required this.lowslot,
  });

  final int id;
  final List<int> highslot;
  final List<int> medslot;
  final List<int> lowslot;

  factory NpcEquipment.fromJson(Map<String, dynamic> json) =>
      _$NpcEquipmentFromJson(json);

  factory NpcEquipment.fromDataDumpMap(Map<String, dynamic> json) {
    var highslots = <int>[];
    var medslots = <int>[];
    var lowslots = <int>[];

    for (var entry in json.entries) {
      if (entry.key.startsWith('highslot')) {
        highslots.add(entry.value);
      } else if (entry.key.startsWith('medslot')) {
        medslots.add(entry.value);
      } else if (entry.key.startsWith('lowslot')) {
        lowslots.add(entry.value);
      } else if (entry.key != 'id') {
        print('Unknown slot type: ${entry.key}');
      }
    }

    return NpcEquipment(
      id: json['id'],
      highslot: highslots,
      medslot: medslots,
      lowslot: lowslots,
    );
  }

  Map<String, dynamic> toJson() => _$NpcEquipmentToJson(this);
}
