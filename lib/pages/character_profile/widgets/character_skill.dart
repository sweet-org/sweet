import 'package:auto_size_text/auto_size_text.dart';
import 'package:collection/collection.dart';
import 'package:intl/intl.dart';
import 'package:sweet/database/entities/item.dart';
import 'package:sweet/pages/character_profile/bloc/character_profile_bloc/bloc.dart';
import 'package:sweet/pages/character_profile/bloc/character_profile_bloc/events.dart';
import 'package:sweet/pages/character_profile/bloc/character_profile_bloc/states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';

import 'package:sweet/model/items/skills.dart';
import 'package:sweet/util/constants.dart';
import 'package:sweet/widgets/localised_text.dart';

class CharacterSkill extends StatefulWidget {
  const CharacterSkill({
    Key? key,
    required this.skill,
  }) : super(key: key);

  final Item skill;

  @override
  State<CharacterSkill> createState() => _CharacterSkillState();
}

class _CharacterSkillState extends State<CharacterSkill> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: BlocBuilder<CharacterProfileBloc, CharacterProfileState>(
          builder: (context, state) {
        var level = state is CharacterProfileUpdated
            ? state.character.learntSkills
                    .firstWhereOrNull(
                      (skill) => skill.skillId == widget.skill.id,
                    )
                    ?.skillLevel ??
                0
            : 0;
        final canBeTrained = state is CharacterProfileUpdated
            ? widget.skill.canBeTrained(
                knownSkills: state.character.learntSkills,
              )
            : false;

        final formatter = NumberFormat.decimalPattern();
        final skillSP = formatter.format(skillSPForLevel(
          skillExp: widget.skill.exp ?? 0,
          skillLevel: level,
        ));

        return InkWell(
          onTap: canBeTrained
              ? () {
                  // Mod 6 to roll over into 0 - 5 range
                  final newLevel = ++level % 6;

                  context
                      .read<CharacterProfileBloc>()
                      .add(UpdateCharacterSkill(newLevel, widget.skill.id));
                }
              : null,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LocalisedText(
                        item: widget.skill,
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                              color: canBeTrained
                                  ? Theme.of(context).textTheme.bodyLarge!.color
                                  : Theme.of(context)
                                      .textTheme
                                      .bodyLarge!
                                      .color!
                                      .withAlpha(128),
                            ),
                      ),
                      AutoSizeText(
                        '$skillSP SP',
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                              color: canBeTrained
                                  ? Theme.of(context).textTheme.bodySmall!.color
                                  : Theme.of(context)
                                      .textTheme
                                      .bodySmall!
                                      .color!
                                      .withAlpha(128),
                            ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 4.0),
                  child: SizedBox.fromSize(
                    size: Size(64, 32),
                    child: canBeTrained
                        ? StepProgressIndicator(
                            totalSteps: 5,
                            currentStep: canBeTrained ? level : 0,
                            size: 8,
                          )
                        : Container(),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
