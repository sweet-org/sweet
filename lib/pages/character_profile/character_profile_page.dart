import 'package:sweet/model/character/character.dart';
import 'package:sweet/repository/character_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sweet/repository/item_repository.dart';
import 'package:sweet/repository/localisation_repository.dart';

import 'bloc/character_profile_bloc/bloc.dart';
import 'widgets/character_profile_header.dart';
import 'widgets/character_skill_browser.dart';

class CharacterProfilePage extends StatelessWidget {
  static const routeName = '/character';
  final Character character;

  const CharacterProfilePage({super.key, required this.character});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider<CharacterProfileBloc>(
        create: (context) => CharacterProfileBloc(
          characterId: character.id,
          characterRepository:
              RepositoryProvider.of<CharacterRepository>(context),
          itemRepository: RepositoryProvider.of<ItemRepository>(context),
          localisationRepository:
              RepositoryProvider.of<LocalisationRepository>(context),
        ),
        child: Material(
          child: Column(
            verticalDirection: VerticalDirection.up,
            children: [
              CharacterSkillBrowser(),
              CharacterProfileHeader(),
            ],
          ),
        ),
      ),
    );
  }
}
