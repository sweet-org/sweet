// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ship_fitting_folder.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ShipFittingFolder _$ShipFittingFolderFromJson(Map<String, dynamic> json) =>
    ShipFittingFolder(
      id: json['id'] as String?,
      name: json['name'] as String,
      contents: (json['contents'] as List<dynamic>?)
          ?.map((e) => FittingListElement.fromJson(e as Map<String, dynamic>))
          .toList(),
      type: json['type'] as String?,
    );

Map<String, dynamic> _$ShipFittingFolderToJson(ShipFittingFolder instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': instance.type,
      'contents': instance.contents,
    };
