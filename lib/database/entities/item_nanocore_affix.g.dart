// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_nanocore_affix.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ItemNanocoreAffix _$ItemNanocoreAffixFromJson(Map<String, dynamic> json) =>
    ItemNanocoreAffix(
      attrId: (json['attrId'] as num).toInt(),
      attrFirstClass: (json['attrFirstClass'] as num).toInt(),
      attrSecondClass: (json['attrSecondClass'] as num).toInt(),
      attrGroup: (json['attrGroup'] as num).toInt(),
      attrLevel: (json['attrLevel'] as num).toInt(),
      attrCount: (json['attrCount'] as num).toInt(),
      children: (json['children'] as List<dynamic>?)
          ?.map((e) => ItemNanocoreAffix.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ItemNanocoreAffixToJson(ItemNanocoreAffix instance) =>
    <String, dynamic>{
      'attrId': instance.attrId,
      'attrFirstClass': instance.attrFirstClass,
      'attrSecondClass': instance.attrSecondClass,
      'attrGroup': instance.attrGroup,
      'attrLevel': instance.attrLevel,
      'attrCount': instance.attrCount,
      'children': instance.children,
    };
