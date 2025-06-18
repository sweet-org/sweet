import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:sweet/database/entities/item.dart';
import 'package:sweet/model/character/character.dart';
import 'package:sweet/repository/item_repository.dart';
import 'package:sweet/util/constants.dart';

class CharacterTotalSkillPoints extends StatelessWidget {
  const CharacterTotalSkillPoints({
    super.key,
    required this.character,
    this.style,
  });
  final Character character;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final itemRepo = RepositoryProvider.of<ItemRepository>(context);
    return FutureBuilder<Iterable<Item>>(
      future: itemRepo.skillItems,
      builder: (context, snapshot) {
        final skills = snapshot.data;
        if (skills == null) {
          return Container();
        }
        final skillsMap = {for (var skill in skills) skill.id: skill};
        final totalSP =
            character.learntSkills.fold<int>(0, (previousValue, learntSkill) {
          if (!skillsMap.containsKey(learntSkill.skillId)) return previousValue;
          final skill = skillsMap[learntSkill.skillId]!;
          return previousValue += skillSPForLevel(
              skillExp: skill.exp ?? 0, skillLevel: learntSkill.skillLevel);
        });

        final formatter = NumberFormat.decimalPattern();
        final skillSP = '${formatter.format(totalSP)} SP';
        return AutoSizeText(
          skillSP,
          style: style ?? Theme.of(context).textTheme.bodySmall,
        );
      },
    );
  }
}
