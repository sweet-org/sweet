import 'package:flutter/services.dart';
import 'package:sweet/mixins/scan_qrcode_mixin.dart';
import 'package:sweet/model/character/character.dart';
import 'package:sweet/pages/character_browser/bloc/character_browser_bloc/states.dart';
import 'package:sweet/pages/character_profile/character_profile_page.dart';
import 'package:sweet/util/localisation_constants.dart';
import 'package:sweet/util/platform_helper.dart';
import 'package:sweet/widgets/localised_text.dart';
import 'package:sweet/widgets/speed_dial_fab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/character_browser_bloc/bloc.dart';
import '../bloc/character_browser_bloc/events.dart';
import 'character_card.dart';

class CharacterListView extends StatelessWidget with ScanQrCode {
  final _characterNameController = TextEditingController();

  Future<void> fittingFromClipboard(BuildContext context) async {
    final data = await Clipboard.getData('text/plain');

    addCharacterFromString(data?.text, context);
  }

  void addCharacterFromString(String? data, BuildContext context) {
    if (data != null) {
      try {
        var character = Character.fromQrCodeData(data);
        context.read<CharacterBrowserBloc>().add(
              ImportCharacter(character: character),
            );
      } on FormatException {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(StaticLocalisationStrings.invalidFormatDetected),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> addCharacter(BuildContext widgetContext) async {
    return showDialog<void>(
      context: widgetContext,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: LocalisedText(
            localiseId: LocalisationStrings.addClone,
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                LocalisedText(
                  localiseId: LocalisationStrings.pleaseEnterName,
                ),
                TextField(
                  controller: _characterNameController,
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
                if (_characterNameController.text.isNotEmpty) {
                  widgetContext.read<CharacterBrowserBloc>().add(
                      AddNewCharacter(
                          characterName: _characterNameController.text));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: _buildFab(context),
      body: BlocBuilder<CharacterBrowserBloc, CharacterBrowserState>(
          builder: (context, state) {
        if (state is CharacterBrowserLoaded) {
          var charList = state.characters.toList();
          if (charList.isEmpty) {
            return _buildEmptyState();
          } else {
            return ReorderableListView.builder(
              itemCount: charList.length,
              onReorder: (oldIndex, newIndex) {
                final character = charList[oldIndex];
                if (oldIndex < newIndex) {
                  // removing the item at oldIndex will shorten the list by 1.
                  // https://api.flutter.dev/flutter/widgets/ReorderCallback.html
                  newIndex -= 1;
                }

                context.read<CharacterBrowserBloc>().add(
                      ReorderCharacter(
                        character: character,
                        newIndex: newIndex,
                      ),
                    );
              },
              itemBuilder: (context, index) => _buildCharacterCard(
                context,
                charList[index],
                state.totalSkillCount,
              ),
            );
          }
        }
        return Center(
          child: CircularProgressIndicator(),
        );
      }),
    );
  }

  SpeedDialFab _buildFab(BuildContext context) {
    return SpeedDialFab(
      buttonClosedColor: Theme.of(context).primaryColor,
      children: [
        SizedBox.fromSize(
          size: Size.square(48),
          child: RawMaterialButton(
            onPressed: () => addCharacter(context),
            fillColor: Theme.of(context).primaryColor,
            shape: CircleBorder(),
            child: Icon(
              Icons.person_add,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox.fromSize(
          size: Size.square(48),
          child: RawMaterialButton(
            onPressed: () => fittingFromClipboard(context),
            fillColor: Theme.of(context).primaryColor,
            shape: CircleBorder(),
            child: Icon(
              Icons.content_paste,
              color: Colors.white,
            ),
          ),
        ),
        PlatformHelper.isMobile
            ? SizedBox.fromSize(
                size: Size.square(48),
                child: RawMaterialButton(
                  onPressed: () => scanQrCode(
                    context: context,
                    onScan: (data) => addCharacterFromString(
                      data,
                      context,
                    ),
                  ),
                  fillColor: Theme.of(context).primaryColor,
                  shape: CircleBorder(),
                  child: Center(
                      child: Icon(
                    Icons.qr_code_scanner,
                    color: Colors.white,
                  )),
                ),
              )
            : Container(
                width: 1,
                height: 1,
              ),
      ],
    );
  }

  Container _buildEmptyState() {
    return Container(
      child: Center(
        child: Text(
          'No Characters found.\nAdd some!',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildCharacterCard(
    BuildContext context,
    Character character,
    int totalSkillCount,
  ) {
    return CharacterCard(
      key: Key(character.id),
      showDelete: true,
      showClone: true,
      character: character,
      totalSkills: totalSkillCount,
      onTap: (character) => Navigator.pushNamed(
        context,
        CharacterProfilePage.routeName,
        arguments: character,
      ),
    );
  }
}
