// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'effect.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Effect _$EffectFromJson(Map<String, dynamic> json) => Effect(
      disallowAutoRepeat: json['disallowAutoRepeat'] as bool,
      dischargeAttributeId: json['dischargeAttributeId'] as int,
      durationAttributeId: json['durationAttributeId'] as int,
      effectCategory: json['effectCategory'] as int,
      id: json['id'] as int,
      effectName: json['effectName'] as String,
      electronicChance: json['electronicChance'] as bool,
      falloffAttributeId: json['falloffAttributeId'] as int,
      fittingUsageChanceAttributeId:
          json['fittingUsageChanceAttributeId'] as int,
      guid: json['guid'] as String,
      isAssistance: json['isAssistance'] as bool,
      isOffensive: json['isOffensive'] as bool,
      isWarpSafe: json['isWarpSafe'] as bool,
      rangeAttributeId: json['rangeAttributeId'] as int,
      rangeChance: json['rangeChance'] as bool,
      trackingSpeedAttributeId: json['trackingSpeedAttributeId'] as int,
    );

Map<String, dynamic> _$EffectToJson(Effect instance) => <String, dynamic>{
      'disallowAutoRepeat': instance.disallowAutoRepeat,
      'dischargeAttributeId': instance.dischargeAttributeId,
      'durationAttributeId': instance.durationAttributeId,
      'effectCategory': instance.effectCategory,
      'id': instance.id,
      'effectName': instance.effectName,
      'electronicChance': instance.electronicChance,
      'falloffAttributeId': instance.falloffAttributeId,
      'fittingUsageChanceAttributeId': instance.fittingUsageChanceAttributeId,
      'guid': instance.guid,
      'isAssistance': instance.isAssistance,
      'isOffensive': instance.isOffensive,
      'isWarpSafe': instance.isWarpSafe,
      'rangeAttributeId': instance.rangeAttributeId,
      'rangeChance': instance.rangeChance,
      'trackingSpeedAttributeId': instance.trackingSpeedAttributeId,
    };
