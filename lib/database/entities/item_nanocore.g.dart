// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_nanocore.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ItemNanocore _$ItemNanocoreFromJson(Map<String, dynamic> json) => ItemNanocore(
      itemId: json['itemId'] as int,
      filmGroup: json['filmGroup'] as String,
      filmQuality: json['filmQuality'] as int,
      availableShips: (json['availableShips'] as List<dynamic>)
          .map((e) => e as int)
          .toList(),
      selectableModifierItems:
          (json['selectableModifierItems'] as List<dynamic>)
              .map((e) => e as int)
              .toList(),
      trainableModifierItems: (json['trainableModifierItems'] as List<dynamic>)
          .map((e) => (e as List<dynamic>).map((e) => e as int).toList())
          .toList(),
    );

Map<String, dynamic> _$ItemNanocoreToJson(ItemNanocore instance) =>
    <String, dynamic>{
      'itemId': instance.itemId,
      'filmGroup': instance.filmGroup,
      'filmQuality': instance.filmQuality,
      'availableShips': instance.availableShips,
      'selectableModifierItems': instance.selectableModifierItems,
      'trainableModifierItems': instance.trainableModifierItems,
    };
