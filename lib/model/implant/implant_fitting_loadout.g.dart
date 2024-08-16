// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'implant_fitting_loadout.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ImplantFittingLoadout _$ImplantFittingLoadoutFromJson(
        Map<String, dynamic> json) =>
    ImplantFittingLoadout(
      id: json['id'] as String?,
      name: json['name'] as String,
      implantItemId: json['implantItemId'] as int,
      modules: (json['modules'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(int.parse(k),
            ImplantFittingSlotModule.fromJson(e as Map<String, dynamic>)),
      ),
      level: json['level'] as int?,
      type: json['type'] as String?,
    );

Map<String, dynamic> _$ImplantFittingLoadoutToJson(
        ImplantFittingLoadout instance) =>
    <String, dynamic>{
      'id': instance.id,
      'implantItemId': instance.implantItemId,
      'name': instance.name,
      'type': instance.type,
      'level': instance.level,
      'modules': instance.modules.map((k, e) => MapEntry(k.toString(), e)),
    };
