import 'package:sweet/model/character/learned_skill.dart';
import 'package:flutter/material.dart';
import 'package:sweet/database/entities/item.dart';

class GroupSkillsIndicator extends StatelessWidget {
  const GroupSkillsIndicator({
    Key? key,
    required this.skills,
    required this.characterSkills,
  }) : super(key: key);

  final Iterable<Item> skills;
  final List<LearnedSkill> characterSkills;

  @override
  Widget build(BuildContext context) {
    var indicators = skills.map((item) {
      var color = Colors.grey;

      if (characterSkills.any(
        (s) => s.skillId == item.id && s.skillLevel > 0,
      )) {
        var skill =
            characterSkills.firstWhere((learnt) => learnt.skillId == item.id);

        color = skill.skillLevel == 5 ? Colors.green : Colors.blue;
      }

      return Padding(
        padding: const EdgeInsets.all(1.0),
        child: SizedBox.fromSize(
          size: Size.square(6),
          child: Container(
            color: color,
          ),
        ),
      );
    }).toList();

    return Wrap(
      alignment: WrapAlignment.end,
      children: indicators,
    );
  }
}
