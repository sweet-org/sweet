import 'package:auto_size_text/auto_size_text.dart';
import 'package:sweet/model/character/character.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sweet/util/localisation_constants.dart';
import 'package:sweet/widgets/character_total_skill_points.dart';
import 'package:sweet/widgets/localised_text.dart';

import '../bloc/character_browser_bloc/bloc.dart';
import '../bloc/character_browser_bloc/events.dart';

typedef CharacterCallback = void Function(Character character);

class CharacterCard extends StatelessWidget {
  final Character character;
  final CharacterCallback onTap;
  final int totalSkills;
  final bool showDelete;
  final bool showClone;

  const CharacterCard({
    super.key,
    required this.character,
    required this.onTap,
    this.showDelete = false,
    this.showClone = false,
    this.totalSkills = 0,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: character,
      child: InkWell(
        onTap: () => onTap(character),
        child: Card(
          color: Theme.of(context).colorScheme.surfaceContainer,
          clipBehavior: Clip.antiAlias,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: 72),
            child: Padding(
              padding: const EdgeInsets.only(
                top: 8.0,
                bottom: 8.0,
                left: 8.0,
                right: 32.0,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.person,
                    size: 56.0,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  Expanded(
                    flex: 2,
                    child: Consumer<Character>(
                      builder: (context, character, child) {
                        var knownSkills = character.learntSkills
                            .where((s) => s.skillLevel > 0)
                            .length;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AutoSizeText(
                              character.name,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 40,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                              maxLines: 1,
                            ),
                            Text(
                              'Skills Known: $knownSkills/$totalSkills',
                              style: TextStyle(
                                fontSize: 16,
                                color: Theme.of(context).colorScheme
                                    .onSurface.withAlpha(180),
                              ),
                            ),
                            CharacterTotalSkillPoints(
                              character: character,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context).colorScheme
                                        .onSurface.withAlpha(180),
                                  ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  showDelete
                      ? IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => deleteCharacter(context, character),
                        )
                      : Container(),
                  showClone
                      ? IconButton(
                          icon: Icon(Icons.file_copy),
                          onPressed: () => cloneCharacter(context, character),
                        )
                      : Container(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> cloneCharacter(
    BuildContext widgetContext,
    Character character,
  ) async {
    final characterNameController =
        TextEditingController(text: '${character.name} (Cloned)');
    return showDialog<void>(
      context: widgetContext,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Clone character'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                LocalisedText(
                  localiseId: LocalisationStrings.pleaseEnterName,
                ),
                TextField(
                  controller: characterNameController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Character name',
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: LocalisedText(
                localiseId: LocalisationStrings.cancel,
              ),
            ),
            TextButton(
              onPressed: () {
                if (characterNameController.text.isNotEmpty) {
                  widgetContext.read<CharacterBrowserBloc>().add(
                        CloneCharacter(
                          character: character,
                          characterName: characterNameController.text,
                        ),
                      );
                  Navigator.of(context).pop();
                }
              },
              child: LocalisedText(localiseId: LocalisationStrings.ok),
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteCharacter(
    BuildContext widgetContext,
    Character character,
  ) {
    return showDialog<void>(
      context: widgetContext,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(StaticLocalisationStrings.deleteClone),
          content: Text(
              'Are you sure you want to delete this character?\n\nThis action cannot be reversed.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: LocalisedText(
                localiseId: LocalisationStrings.cancel,
              ),
            ),
            TextButton(
              onPressed: () {
                widgetContext
                    .read<CharacterBrowserBloc>()
                    .add(DeleteCharacter(characterId: character.id));
                Navigator.of(context).pop();
              },
              child: LocalisedText(localiseId: LocalisationStrings.ok),
            ),
          ],
        );
      },
    );
  }
}
