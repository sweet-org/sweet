// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_effect.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ItemEffect _$ItemEffectFromJson(Map<String, dynamic> json) => ItemEffect(
      (json['effectId'] as num).toInt(),
      json['isDefault'] as bool,
      (json['itemId'] as num).toInt(),
    );

Map<String, dynamic> _$ItemEffectToJson(ItemEffect instance) =>
    <String, dynamic>{
      'itemId': instance.itemId,
      'effectId': instance.effectId,
      'isDefault': instance.isDefault,
    };
