// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attribute.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Attribute _$AttributeFromJson(Map<String, dynamic> json) => Attribute(
      attributeCategory: json['attributeCategory'] as int,
      id: json['id'] as int,
      attributeName: json['attributeName'] as String,
      available: json['available'] as bool,
      chargeRechargeTimeId: json['chargeRechargeTimeId'] as int,
      defaultValue: (json['defaultValue'] as num).toDouble(),
      highIsGood: json['highIsGood'] as bool,
      maxAttributeId: json['maxAttributeId'] as int,
      attributeOperator: (json['attributeOperator'] as List<dynamic>)
          .map((e) => e as int)
          .toList(),
      stackable: json['stackable'] as bool,
      toAttrId:
          (json['toAttrId'] as List<dynamic>).map((e) => e as int).toList(),
      unitId: json['unitId'] as int,
      unitLocalisationKey: json['unitLocalisationKey'] as int?,
      attributeSourceUnit: json['attributeSourceUnit'] as String?,
      attributeTip: json['attributeTip'] as String?,
      attributeSourceName: json['attributeSourceName'] as String?,
      nameLocalisationKey: json['nameLocalisationKey'] as int?,
      tipLocalisationKey: json['tipLocalisationKey'] as int?,
      attributeFormula: json['attributeFormula'] as String? ?? 'A',
      baseValue: (json['baseValue'] as num?)?.toDouble() ?? 0,
    );

Map<String, dynamic> _$AttributeToJson(Attribute instance) => <String, dynamic>{
      'attributeCategory': instance.attributeCategory,
      'id': instance.id,
      'attributeName': instance.attributeName,
      'available': instance.available,
      'chargeRechargeTimeId': instance.chargeRechargeTimeId,
      'defaultValue': instance.defaultValue,
      'highIsGood': instance.highIsGood,
      'maxAttributeId': instance.maxAttributeId,
      'attributeOperator': instance.attributeOperator,
      'stackable': instance.stackable,
      'toAttrId': instance.toAttrId,
      'unitId': instance.unitId,
      'unitLocalisationKey': instance.unitLocalisationKey,
      'attributeSourceUnit': instance.attributeSourceUnit,
      'attributeTip': instance.attributeTip,
      'attributeSourceName': instance.attributeSourceName,
      'nameLocalisationKey': instance.nameLocalisationKey,
      'tipLocalisationKey': instance.tipLocalisationKey,
      'attributeFormula': instance.attributeFormula,
      'baseValue': instance.baseValue,
    };
