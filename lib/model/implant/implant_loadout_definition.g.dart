// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'implant_loadout_definition.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ImplantLoadoutDefinition _$ImplantLoadoutDefinitionFromJson(
        Map<String, dynamic> json) =>
    ImplantLoadoutDefinition(
      slots: (json['slots'] as Map<String, dynamic>).map(
        (k, e) =>
            MapEntry(int.parse(k), $enumDecode(_$ImplantSlotTypeEnumMap, e)),
      ),
      restrictions: (json['restrictions'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(
            int.parse(k), (e as List<dynamic>).map((e) => e as int).toList()),
      ),
    );

Map<String, dynamic> _$ImplantLoadoutDefinitionToJson(
        ImplantLoadoutDefinition instance) =>
    <String, dynamic>{
      'slots': instance.slots
          .map((k, e) => MapEntry(k.toString(), _$ImplantSlotTypeEnumMap[e]!)),
      'restrictions':
          instance.restrictions.map((k, e) => MapEntry(k.toString(), e)),
    };

const _$ImplantSlotTypeEnumMap = {
  ImplantSlotType.branch: 'branch',
  ImplantSlotType.common: 'common',
  ImplantSlotType.upgrade: 'upgrade',
};
