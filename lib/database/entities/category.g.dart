// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Category _$CategoryFromJson(Map<String, dynamic> json) => Category(
      id: json['id'] as int? ?? -1,
      groups: (json['groups'] as List<dynamic>?)
          ?.map((e) => Group.fromJson(e as Map<String, dynamic>))
          .toList(),
      groupIds:
          (json['groupIds'] as List<dynamic>?)?.map((e) => e as int).toList() ??
              const [],
      localisedNameIndex: json['localisedNameIndex'] as int? ?? -1,
      sourceName: json['sourceName'] as String? ?? '',
    );

Map<String, dynamic> _$CategoryToJson(Category instance) {
  final val = <String, dynamic>{
    'id': instance.id,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('groups', instance.groups);
  val['groupIds'] = instance.groupIds;
  val['localisedNameIndex'] = instance.localisedNameIndex;
  val['sourceName'] = instance.sourceName;
  return val;
}
