// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_nanocore.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ItemNanocore _$ItemNanocoreFromJson(Map<String, dynamic> json) => ItemNanocore(
      itemId: (json['itemId'] as num).toInt(),
      filmGroup: json['filmGroup'] as String,
      filmQuality: (json['filmQuality'] as num).toInt(),
      isGold: json['isGold'] as bool,
      otherItemId: (json['otherItemId'] as num).toInt(),
      availableShips: (json['availableShips'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      selectableModifierItems:
          (json['selectableModifierItems'] as List<dynamic>)
              .map((e) => (e as num).toInt())
              .toList(),
      trainableModifierItems: (json['trainableModifierItems'] as List<dynamic>)
          .map((e) =>
              (e as List<dynamic>).map((e) => (e as num).toInt()).toList())
          .toList(),
    );

Map<String, dynamic> _$ItemNanocoreToJson(ItemNanocore instance) =>
    <String, dynamic>{
      'itemId': instance.itemId,
      'filmGroup': instance.filmGroup,
      'filmQuality': instance.filmQuality,
      'isGold': instance.isGold,
      'otherItemId': instance.otherItemId,
      'availableShips': instance.availableShips,
      'selectableModifierItems': instance.selectableModifierItems,
      'trainableModifierItems': instance.trainableModifierItems,
    };
