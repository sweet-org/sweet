// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'learned_skill.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LearnedSkill _$LearnedSkillFromJson(Map<String, dynamic> json) => LearnedSkill(
      skillId: (json['skillId'] as num).toInt(),
      skillLevel: (json['skillLevel'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$LearnedSkillToJson(LearnedSkill instance) =>
    <String, dynamic>{
      'skillId': instance.skillId,
      'skillLevel': instance.skillLevel,
    };
