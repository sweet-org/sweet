

import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'effect.g.dart';

List<Effect> effectsFromJson(String str) =>
    List<Effect>.from(json.decode(str).map((x) => Effect.fromJson(x)));

@JsonSerializable(includeIfNull: true)
class Effect {
  Effect({
    required this.disallowAutoRepeat,
    required this.dischargeAttributeId,
    required this.durationAttributeId,
    required this.effectCategory,
    required this.id,
    required this.effectName,
    required this.electronicChance,
    required this.falloffAttributeId,
    required this.fittingUsageChanceAttributeId,
    required this.guid,
    required this.isAssistance,
    required this.isOffensive,
    required this.isWarpSafe,
    required this.rangeAttributeId,
    required this.rangeChance,
    required this.trackingSpeedAttributeId,
  });

  bool disallowAutoRepeat;
  int dischargeAttributeId;
  int durationAttributeId;
  int effectCategory;
  int id;
  String effectName;
  bool electronicChance;
  int falloffAttributeId;
  int fittingUsageChanceAttributeId;
  String guid;
  bool isAssistance;
  bool isOffensive;
  bool isWarpSafe;
  int rangeAttributeId;
  bool rangeChance;
  int trackingSpeedAttributeId;

  factory Effect.fromJson(Map<String, dynamic> json) => _$EffectFromJson(json);

  Map<String, dynamic> toJson() => _$EffectToJson(this);
}
