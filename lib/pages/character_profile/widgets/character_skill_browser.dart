import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sweet/repository/localisation_repository.dart';
import 'package:sweet/model/items/skills.dart';

import 'package:sweet/pages/character_profile/bloc/character_profile_bloc/bloc.dart';
import 'package:sweet/pages/character_profile/bloc/character_profile_bloc/states.dart';

import 'character_skill.dart';
import 'group_skills_indicator.dart';

class CharacterSkillBrowser extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CharacterProfileBloc, CharacterProfileState>(
        buildWhen: (p, s) => s is CharacterProfileUpdate,
        listener: (ctx, state) {
          if (state is ShowStatusUpdate) {
            ScaffoldMessenger.of(ctx).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is CharacterProfileUpdate && state.showSpinner == false) {
            return Expanded(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: state.skillGroups.length,
                itemBuilder: (context, groupIndex) {
                  final group = state.skillGroups[groupIndex];
                  final skills = group.items!;
                  final canTrainSkills = skills
                      .where(
                        (e) => e.canBeTrained(
                          knownSkills: state.character.learntSkills,
                        ),
                      )
                      .toList();

                  return skills.isNotEmpty
                      ? ExpansionTile(
                          expandedAlignment: Alignment.centerLeft,
                          expandedCrossAxisAlignment:
                              CrossAxisAlignment.stretch,
                          leading: Icon(Icons.adjust),
                          title: Text(
                            RepositoryProvider.of<LocalisationRepository>(
                                    context)
                                .getLocalisedStringForGroup(group),
                          ),
                          subtitle: GroupSkillsIndicator(
                            skills: skills,
                            characterSkills: state.character.learntSkills,
                          ),
                          children: [
                            ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: canTrainSkills.length,
                              itemBuilder: (context, index) {
                                var skill = canTrainSkills[index];
                                return CharacterSkill(skill: skill);
                              },
                            )
                          ],
                        )
                      : Container();
                },
              ),
            );
          } else {
            return Expanded(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
        });
  }
}
