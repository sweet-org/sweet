// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gold_nano_attr_class.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GoldNanoAttrClass _$GoldNanoAttrClassFromJson(Map<String, dynamic> json) =>
    GoldNanoAttrClass(
      classId: (json['classId'] as num).toInt(),
      classLevel: (json['classLevel'] as num).toInt(),
      parentClassId: (json['parentClassId'] as num).toInt(),
      sourceName: json['sourceName'] as String,
      nameKey: (json['nameKey'] as num).toInt(),
      children: (json['children'] as List<dynamic>?)
          ?.map((e) => GoldNanoAttrClass.fromJson(e as Map<String, dynamic>))
          .toList(),
      items: (json['items'] as List<dynamic>?)
          ?.map((e) => ItemNanocoreAffix.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$GoldNanoAttrClassToJson(GoldNanoAttrClass instance) =>
    <String, dynamic>{
      'classId': instance.classId,
      'classLevel': instance.classLevel,
      'parentClassId': instance.parentClassId,
      'sourceName': instance.sourceName,
      'nameKey': instance.nameKey,
      'children': instance.children,
      'items': instance.items,
    };
