

import 'package:sweet/model/character/character.dart';
import 'package:sweet/pages/character_browser/widget/character_card.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sweet/repository/character_repository.dart';
import 'package:flutter/material.dart';
import 'package:sweet/repository/item_repository.dart';

class PilotContextDrawer extends StatelessWidget {
  const PilotContextDrawer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final itemRepo = RepositoryProvider.of<ItemRepository>(context);
    final charRepo = RepositoryProvider.of<CharacterRepository>(context);

    final characters = [
      Character.empty,
      charRepo.lv5Character,
      ...charRepo.characters
    ];

    return Container(
      height: 600,
      color: Theme.of(context).canvasColor,
      child: ListView.builder(
        itemCount: characters.length,
        itemBuilder: (context, index) {
          var character = characters[index];

          return CharacterCard(
            character: character,
            totalSkills: itemRepo.skillItemsCount,
            onTap: (character) => Navigator.pop(context, character),
          );
        },
      ),
    );
  }
}
