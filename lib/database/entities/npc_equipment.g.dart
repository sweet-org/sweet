// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'npc_equipment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NpcEquipment _$NpcEquipmentFromJson(Map<String, dynamic> json) => NpcEquipment(
      id: (json['id'] as num).toInt(),
      highslot: (json['highslot'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      medslot: (json['medslot'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      lowslot: (json['lowslot'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
    );

Map<String, dynamic> _$NpcEquipmentToJson(NpcEquipment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'highslot': instance.highslot,
      'medslot': instance.medslot,
      'lowslot': instance.lowslot,
    };
