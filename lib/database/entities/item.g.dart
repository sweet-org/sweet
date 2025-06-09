// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Item _$ItemFromJson(Map<String, dynamic> json) => Item(
      id: (json['id'] as num).toInt(),
      mainCalCode: json['mainCalCode'] as String?,
      activeCalCode: json['activeCalCode'] as String?,
      onlineCalCode: json['onlineCalCode'] as String?,
      sourceDesc: json['sourceDesc'] as String?,
      sourceName: json['sourceName'] as String?,
      nameKey: (json['nameKey'] as num).toInt(),
      descKey: (json['descKey'] as num?)?.toInt(),
      descSpecial: (json['descSpecial'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
      marketGroupId: (json['marketGroupId'] as num?)?.toInt(),
      exp: (json['exp'] as num?)?.toDouble(),
      published: (json['published'] as num?)?.toInt(),
      preSkill: (json['preSkill'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      shipBonusCodeList: (json['shipBonusCodeList'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      shipBonusSkillList: (json['shipBonusSkillList'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
      product: (json['product'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ItemToJson(Item instance) => <String, dynamic>{
      'id': instance.id,
      'mainCalCode': instance.mainCalCode,
      'onlineCalCode': instance.onlineCalCode,
      'activeCalCode': instance.activeCalCode,
      'sourceDesc': instance.sourceDesc,
      'sourceName': instance.sourceName,
      'nameKey': instance.nameKey,
      'descKey': instance.descKey,
      'descSpecial': instance.descSpecial,
      'marketGroupId': instance.marketGroupId,
      'product': instance.product,
      'preSkill': instance.preSkill,
      'exp': instance.exp,
      'published': instance.published,
      'shipBonusCodeList': instance.shipBonusCodeList,
      'shipBonusSkillList': instance.shipBonusSkillList,
    };
