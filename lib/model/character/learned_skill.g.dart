// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'learned_skill.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LearnedSkill _$LearnedSkillFromJson(Map<String, dynamic> json) => LearnedSkill(
      skillId: json['skillId'] as int,
      skillLevel: json['skillLevel'] as int? ?? 0,
    );

Map<String, dynamic> _$LearnedSkillToJson(LearnedSkill instance) =>
    <String, dynamic>{
      'skillId': instance.skillId,
      'skillLevel': instance.skillLevel,
    };
