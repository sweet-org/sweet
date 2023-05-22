// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Group _$GroupFromJson(Map<String, dynamic> json) => Group(
      id: json['id'] as int,
      localisedNameIndex: json['localisedNameIndex'] as int,
      sourceName: json['sourceName'] as String,
      itemIds:
          (json['itemIds'] as List<dynamic>?)?.map((e) => e as int).toList(),
      items: (json['items'] as List<dynamic>?)
          ?.map((e) => Item.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$GroupToJson(Group instance) {
  final val = <String, dynamic>{
    'id': instance.id,
    'localisedNameIndex': instance.localisedNameIndex,
    'sourceName': instance.sourceName,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('itemIds', instance.itemIds);
  writeNotNull('items', instance.items);
  return val;
}
