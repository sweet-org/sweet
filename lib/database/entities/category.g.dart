// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Category _$CategoryFromJson(Map<String, dynamic> json) => Category(
      id: (json['id'] as num?)?.toInt() ?? -1,
      groups: (json['groups'] as List<dynamic>?)
          ?.map((e) => Group.fromJson(e as Map<String, dynamic>))
          .toList(),
      groupIds: (json['groupIds'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const [],
      localisedNameIndex: (json['localisedNameIndex'] as num?)?.toInt() ?? -1,
      sourceName: json['sourceName'] as String? ?? '',
    );

Map<String, dynamic> _$CategoryToJson(Category instance) => <String, dynamic>{
      'id': instance.id,
      if (instance.groups case final value?) 'groups': value,
      'groupIds': instance.groupIds,
      'localisedNameIndex': instance.localisedNameIndex,
      'sourceName': instance.sourceName,
    };
