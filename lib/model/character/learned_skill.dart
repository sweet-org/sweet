import 'dart:math';

import 'package:json_annotation/json_annotation.dart';

part 'learned_skill.g.dart';

@JsonSerializable()
class LearnedSkill {
  final int skillId;
  int _skillLevel = 0;
  int get skillLevel => _skillLevel;

  LearnedSkill({
    required this.skillId,
    int skillLevel = 0,
  }) : _skillLevel = skillLevel;

  factory LearnedSkill.fromJson(Map<String, dynamic> json) =>
      _$LearnedSkillFromJson(json);

  Map<String, dynamic> toJson() => _$LearnedSkillToJson(this);

  LearnedSkill copy() => LearnedSkill(
        skillId: skillId,
        skillLevel: skillLevel,
      );

  void setSkillLevel(int newLevel) {
    _skillLevel = min(5, max(0, newLevel)); // ensure level is 0 - 5
  }
}
