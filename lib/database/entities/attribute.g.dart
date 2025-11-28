// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attribute.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Attribute _$AttributeFromJson(Map<String, dynamic> json) => Attribute(
      attributeCategory: (json['attributeCategory'] as num).toInt(),
      id: (json['id'] as num).toInt(),
      attributeName: json['attributeName'] as String,
      available: json['available'] as bool,
      chargeRechargeTimeId: (json['chargeRechargeTimeId'] as num).toInt(),
      defaultValue: (json['defaultValue'] as num).toDouble(),
      maxAttributeId: (json['maxAttributeId'] as num).toInt(),
      attributeOperator: (json['attributeOperator'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      stackable: json['stackable'] as bool,
      toAttrId: (json['toAttrId'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      unitId: (json['unitId'] as num).toInt(),
      unitLocalisationKey: (json['unitLocalisationKey'] as num?)?.toInt(),
      attributeSourceUnit: json['attributeSourceUnit'] as String?,
      attributeTip: json['attributeTip'] as String?,
      attributeSourceName: json['attributeSourceName'] as String?,
      nameLocalisationKey: (json['nameLocalisationKey'] as num?)?.toInt(),
      tipLocalisationKey: (json['tipLocalisationKey'] as num?)?.toInt(),
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
