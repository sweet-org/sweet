// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Group _$GroupFromJson(Map<String, dynamic> json) => Group(
      id: (json['id'] as num).toInt(),
      localisedNameIndex: (json['localisedNameIndex'] as num).toInt(),
      sourceName: json['sourceName'] as String,
      itemIds: (json['itemIds'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
      items: (json['items'] as List<dynamic>?)
          ?.map((e) => Item.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$GroupToJson(Group instance) => <String, dynamic>{
      'id': instance.id,
      'localisedNameIndex': instance.localisedNameIndex,
      'sourceName': instance.sourceName,
      if (instance.itemIds case final value?) 'itemIds': value,
      if (instance.items case final value?) 'items': value,
    };
