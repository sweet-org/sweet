import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sweet/model/ship/ship_fitting_loadout.dart';
import 'package:sweet/pages/fittings_list/bloc/ship_fitting_browser_bloc/ship_fitting_browser_bloc.dart';
import 'package:sweet/repository/item_repository.dart';
import 'package:sweet/repository/ship_fitting_repository.dart';
import 'package:sweet/util/localisation_constants.dart';
import 'package:sweet/widgets/localised_text.dart';

typedef ShipFittingLoadoutCallback = void Function(ShipFittingLoadout loadout);

class ShipFittingCard extends StatelessWidget {
  final ShipFittingLoadout loadout;
  final ShipFittingLoadoutCallback onTap;

  const ShipFittingCard({super.key, required this.loadout, required this.onTap});

  @override
  Widget build(BuildContext context) {
    var itemRepo = RepositoryProvider.of<ItemRepository>(context);
    return ChangeNotifierProvider.value(
      value: loadout,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => onTap(loadout),
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
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Icon(
                      Icons.polymer,
                      size: 48.0,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Consumer<ShipFittingLoadout>(
                      builder: (context, loadout, child) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AutoSizeText(
                              loadout.name,
                              style: Theme.of(context).textTheme.titleLarge,
                              maxLines: 1,
                            ),
                            FutureBuilder<String>(
                              initialData: '',
                              future: itemRepo
                                  .itemName(id: loadout.shipItemId)
                                  .then((value) => value!),
                              builder: (context, snapshot) => AutoSizeText(
                                snapshot.data ?? 'Unknown Hull',
                                style: Theme.of(context).textTheme.bodyMedium,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  FittingControls(loadout: loadout)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FittingControls extends StatefulWidget {
  final ShipFittingLoadout loadout;

  const FittingControls({super.key, required this.loadout});

  @override
  State<FittingControls> createState() => _FittingControlsState();
}

class _FittingControlsState extends State<FittingControls> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return _isExpanded
        ? Row(
            children: [
              IconButton(
                  icon: Icon(Icons.snippet_folder_rounded),
                  onPressed: () =>
                      moveLoadoutToFolder(context, widget.loadout)),
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () => deleteLoadout(context, widget.loadout),
              ),
              IconButton(
                icon: Icon(Icons.file_copy),
                onPressed: () => copyLoadout(context, widget.loadout),
              ),
              IconButton(
                  onPressed: _toggleControls, icon: Icon(Icons.close_fullscreen)
              )
            ],
          )
        : IconButton(
            onPressed: _toggleControls, icon: Icon(Icons.more_vert)
    );
  }

  void _toggleControls() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  Future<void> copyLoadout(
    BuildContext widgetContext,
    ShipFittingLoadout loadout,
  ) async {
    final nameController =
        TextEditingController(text: '${loadout.name} (Cloned)');
    return showDialog<void>(
      context: widgetContext,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Clone fitting'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                LocalisedText(
                  localiseId: LocalisationStrings.pleaseEnterName,
                ),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Fitting name',
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
                if (nameController.text.isNotEmpty) {
                  widgetContext.read<ShipFittingBrowserBloc>().add(
                        CloneShipFitting(
                          shipFitting: loadout,
                          fittingName: nameController.text,
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

  Future<void> deleteLoadout(
      BuildContext widgetContext, ShipFittingLoadout loadout) {
    return showDialog<void>(
      context: widgetContext,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(StaticLocalisationStrings.deleteFitting),
          content: Text(
              'Are you sure you want to delete this fitting?\n\nThis action cannot be reversed.'),
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
                    .read<ShipFittingBrowserBloc>()
                    .add(DeleteShipFitting(shipFittingId: loadout.id));
                Navigator.of(context).pop();
              },
              child: LocalisedText(localiseId: LocalisationStrings.ok),
            ),
          ],
        );
      },
    );
  }

  Future<void> moveLoadoutToFolder(
      BuildContext widgetContext, ShipFittingLoadout loadout) {
    var fittingRepo =
        RepositoryProvider.of<ShipFittingLoadoutRepository>(widgetContext);
    return showDialog<void>(
      context: widgetContext,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(StaticLocalisationStrings.moveToFolder),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                    'Select the target folder or press "No Folder" to move it out of the current folder'),
                DropdownButton<String>(
                    isExpanded: true,
                    items: fittingRepo
                        .getAllFolders()
                        .map<DropdownMenuItem<String>>((f) => DropdownMenuItem(
                              child: Text(f.name),
                              value: f.id,
                            ))
                        .toList(),
                    onChanged: (id) {
                      widgetContext
                          .read<ShipFittingBrowserBloc>()
                          .add(MoveFittingToFolder(loadout, id ?? ""));
                      Navigator.of(context).pop();
                    })
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
                widgetContext
                    .read<ShipFittingBrowserBloc>()
                    .add(MoveFittingToFolder(loadout, ""));
                Navigator.of(context).pop();
              },
              child: Text("No Folder"),
            ),
          ],
        );
      },
    );
  }
}
