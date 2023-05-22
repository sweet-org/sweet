// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_effect.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ItemEffect _$ItemEffectFromJson(Map<String, dynamic> json) => ItemEffect(
      json['effectId'] as int,
      json['isDefault'] as bool,
      json['itemId'] as int,
    );

Map<String, dynamic> _$ItemEffectToJson(ItemEffect instance) =>
    <String, dynamic>{
      'itemId': instance.itemId,
      'effectId': instance.effectId,
      'isDefault': instance.isDefault,
    };
