// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'level_attribute.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LevelAttribute _$LevelAttributeFromJson(Map<String, dynamic> json) =>
    LevelAttribute(
      attrId: (json['attrId'] as num).toInt(),
      formula: json['formula'] as String,
    );

Map<String, dynamic> _$LevelAttributeToJson(LevelAttribute instance) =>
    <String, dynamic>{
      'attrId': instance.attrId,
      'formula': instance.formula,
    };
