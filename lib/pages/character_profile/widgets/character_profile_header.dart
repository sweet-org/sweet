import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sweet/mixins/file_selector_mixin.dart';

import 'package:sweet/model/character/character.dart';
import 'package:sweet/pages/character_profile/bloc/character_profile_bloc/bloc.dart';
import 'package:sweet/pages/character_profile/bloc/character_profile_bloc/events.dart';
import 'package:sweet/pages/character_profile/bloc/character_profile_bloc/states.dart';
import 'package:sweet/util/localisation_constants.dart';
import 'package:sweet/widgets/character_total_skill_points.dart';
import 'package:sweet/widgets/qrcode_dialog.dart';

class CharacterProfileHeader extends StatefulWidget {
  @override
  State<CharacterProfileHeader> createState() => _CharacterProfileHeaderState();
}

class _CharacterProfileHeaderState extends State<CharacterProfileHeader>
    with FileSelector {
  bool editMode = false;

  String _name = '';
  String _id = '';
  int _totalImplantLevels = 0;

  final _formKey = GlobalKey<FormState>();
  void toggleEdit() {
    setState(() {
      if (editMode) {
        final state = _formKey.currentState;
        if (state == null) return;

        state.save();
        if (!state.validate()) return;

        context
            .read<CharacterProfileBloc>()
            .add(UpdateCharacterDetails(_name, _id, _totalImplantLevels));
      }

      editMode = !editMode;
    });
  }

  void showQRCode(Character character) {
    var json = character.generateQrCodeData();
    showDialog(
        context: context,
        builder: (context) => QRCodeDialog(
              data: json,
              title: character.name,
            ));
  }

  Future<void> showImportExportDialog(
    BuildContext widgetContext, {
    required Character character,
  }) async {
    return showDialog<void>(
      context: widgetContext,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return ImportExportDialog(
          title: 'Import/Export skills',
          description:
              'Importing will override all skills and cannot be undone.\n\nExpected in CSV format (ID, Name, Level)',
          onExport: () => _exportFromFile(character: character),
          onImport: () => _importFromFile(character: character),
        );
      },
    );
  }

  Future<void> _exportFromFile({
    required Character character,
  }) async {
    final path = await selectFolder();

    if (path != null) {
      RepositoryProvider.of<CharacterProfileBloc>(context).add(
        ExportCharacterSkills(filePath: path),
      );
    }
  }

  Future<void> _importFromFile({
    required Character character,
  }) async {
    final path = await selectFile();

    if (path != null) {
      RepositoryProvider.of<CharacterProfileBloc>(context).add(
        ImportCharacterSkills(filePath: path),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        elevation: 5,
        color: Theme.of(context).primaryColor,
        child: SafeArea(
          child: Container(
            child: ConstrainedBox(
              constraints: BoxConstraints.loose(
                Size.fromHeight(
                  192,
                ),
              ),
              child: BlocBuilder<CharacterProfileBloc, CharacterProfileState>(
                buildWhen: (prev, curr) => curr is CharacterProfileUpdate,
                builder: (context, state) {
                  if (state is CharacterProfileUpdate &&
                      state.showSpinner == false) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Column(
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                              ),
                              onPressed: () => Navigator.pop(context),
                            ),
                            IconButton(
                              icon: Icon(
                                editMode ? Icons.save : Icons.edit,
                                color: Colors.white,
                              ),
                              onPressed: () => toggleEdit(),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.qr_code,
                                color: Colors.white,
                              ),
                              onPressed: () => showQRCode(state.character),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.import_export,
                                color: Colors.white,
                              ),
                              onPressed: () => showImportExportDialog(
                                context,
                                character: state.character,
                              ),
                            ),
                          ],
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Expanded(
                                  child: FittedBox(
                                    fit: BoxFit.fill,
                                    child: Icon(
                                      Icons.person,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                editMode
                                    ? _buildCharacterDetailsForm(
                                        formKey: _formKey,
                                        character: state.character,
                                      )
                                    : CharacterProfileHeaderDetails(
                                        character: state.character,
                                      )
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  } else {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              ),
            ),
          ),
        ));
  }

  Form _buildCharacterDetailsForm({
    Key? formKey,
    required Character character,
  }) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          TextFormField(
            initialValue: character.name,
            cursorColor: Colors.black,
            style: TextStyle(color: Colors.white),
            decoration:
                InputDecoration(labelText: 'Enter Name', hintText: 'Name'),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a name';
              }
              return null;
            },
            onSaved: (value) {
              setState(() {
                if (value != null) {
                  _name = value;
                }
              });
            },
          ),
          TextFormField(
            initialValue: character.id,
            cursorColor: Colors.black,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
                labelText: 'Enter ID',
                hintText: 'This is on the character screen'),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a name';
              }
              return null;
            },
            onSaved: (value) {
              setState(() {
                if (value != null) {
                  _id = value;
                }
              });
            },
          ),
          TextFormField(
            initialValue: "0",
            cursorColor: Colors.black,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
                labelText: 'Enter total implant levels',
                hintText: 'The sum of all implant levels'),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a number';
              }
              if (int.tryParse(value.trim()) == null) {
                return 'Please enter a valid number';
              }
              final val = int.parse(value.trim());
              if (val <= 0) {
                return 'Please enter a positive number';
              }
              return null;
            },
            onSaved: (value) {
              setState(() {
                if (value != null) {
                  _totalImplantLevels = int.tryParse(value.trim())
                      ?? _totalImplantLevels;
                }
              });
            },
          ),
        ],
      ),
    );
  }
}

class CharacterProfileHeaderDetails extends StatelessWidget {
  const CharacterProfileHeaderDetails({
    Key? key,
    required this.character,
  }) : super(key: key);

  final Character character;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          character.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 30,
          ),
        ),
        CharacterTotalSkillPoints(
          character: character,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white.withAlpha(96),
              ),
        ),
        Text("${character.totalImplantLevels} Implant Levels",
            style: TextStyle(
              color: Colors.white.withAlpha(96),
              fontSize: 14,
            )),
        Text(
          character.id,
          style: TextStyle(
            color: Colors.white.withAlpha(96),
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

class ImportExportDialog extends StatelessWidget {
  ImportExportDialog({
    Key? key,
    required this.title,
    required this.description,
    required this.onExport,
    required this.onImport,
  }) : super(key: key) {
    assert(title.trim().isNotEmpty, 'Must have a title');
    assert(description.trim().isNotEmpty, 'Must have a description');
  }

  final String title;
  final String description;

  final VoidCallback onExport;
  final VoidCallback onImport;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      actionsAlignment: MainAxisAlignment.start,
      actionsOverflowDirection: VerticalDirection.down,
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Text(
              description,
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onExport();
          },
          child: Text(StaticLocalisationStrings.exportToFile),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onImport();
          },
          child: Text(StaticLocalisationStrings.importFromFile),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(StaticLocalisationStrings.close),
        ),
      ],
    );
  }
}
