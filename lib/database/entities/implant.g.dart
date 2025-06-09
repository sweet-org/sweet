// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'implant.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Implant _$ImplantFromJson(Map<String, dynamic> json) => Implant(
      id: (json['id'] as num).toInt(),
      originalTypeId: (json['originalTypeId'] as num).toInt(),
      rarity: (json['rarity'] as num).toInt(),
      implantType: (json['implantType'] as num).toInt(),
      implantFramework: (json['implantFramework'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(
            k, (e as List<dynamic>).map((e) => (e as num).toInt()).toList()),
      ),
    );

Map<String, dynamic> _$ImplantToJson(Implant instance) => <String, dynamic>{
      'id': instance.id,
      'originalTypeId': instance.originalTypeId,
      'rarity': instance.rarity,
      'implantType': instance.implantType,
      'implantFramework': instance.implantFramework,
    };
