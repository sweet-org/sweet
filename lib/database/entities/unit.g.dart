// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Unit _$UnitFromJson(Map<String, dynamic> json) => Unit(
      id: (json['id'] as num).toInt(),
      description: json['description'] as String?,
      displayName: json['displayName'] as String?,
      unitName: json['unitName'] as String,
    );

Map<String, dynamic> _$UnitToJson(Unit instance) => <String, dynamic>{
      'id': instance.id,
      'description': instance.description,
      'displayName': instance.displayName,
      'unitName': instance.unitName,
    };
