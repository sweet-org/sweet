// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'implant.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Implant _$ImplantFromJson(Map<String, dynamic> json) => Implant(
      id: json['id'] as int,
      originalTypeId: json['originalTypeId'] as int,
      rarity: json['rarity'] as int,
      implantType: json['implantType'] as int,
      implantFramework: (json['implantFramework'] as Map<String, dynamic>).map(
        (k, e) =>
            MapEntry(k, (e as List<dynamic>).map((e) => e as int).toList()),
      ),
    );

Map<String, dynamic> _$ImplantToJson(Implant instance) => <String, dynamic>{
      'id': instance.id,
      'originalTypeId': instance.originalTypeId,
      'rarity': instance.rarity,
      'implantType': instance.implantType,
      'implantFramework': instance.implantFramework,
    };
