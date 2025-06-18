import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sweet/model/ship/ship_fitting_folder.dart';

import 'package:sweet/model/ship/ship_fitting_loadout.dart';
import 'package:sweet/pages/fittings_list/bloc/ship_fitting_browser_bloc/bloc.dart';
import 'package:sweet/pages/fittings_list/bloc/ship_fitting_browser_bloc/events.dart';
import 'package:sweet/pages/fittings_list/widgets/ship_fitting_card.dart';
import 'package:sweet/util/localisation_constants.dart';
import 'package:sweet/widgets/localised_text.dart';

/// Represents a folder that can contains multiple ship fittings.
class FittingFolderCard extends StatefulWidget {
  final ShipFittingFolder folder;
  final Future<void> Function(ShipFittingLoadout loadout) onLoadoutTap;

  const FittingFolderCard(
      {super.key, required this.folder, required this.onLoadoutTap});

  @override
  State<StatefulWidget> createState() => _FittingFolderState();
}

class _FittingFolderState extends State<FittingFolderCard> {
  bool _isExpaned = false;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: widget.folder,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: _toggleFolder,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: 72),
            child: Padding(
              padding: const EdgeInsets.only(
                top: 8.0,
                bottom: 8.0,
                left: 8.0,
                right: 32.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Icon(
                          _isExpaned ? Icons.folder_open : Icons.folder,
                          size: 48.0,
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AutoSizeText(
                              widget.folder.name,
                              style: Theme
                                  .of(context)
                                  .textTheme
                                  .titleLarge,
                              maxLines: 1,
                            ),
                            AutoSizeText(
                              _isExpaned ? "Tap to close" : "Tap to open",
                              style: Theme
                                  .of(context)
                                  .textTheme
                                  .bodyMedium,
                              maxLines: 1,
                            ),
                            AutoSizeText(
                              widget.folder.getSize().toString() +
                                  (widget.folder.getSize() == 1
                                      ? " Fitting"
                                      : " Fittings"),
                              style: Theme
                                  .of(context)
                                  .textTheme
                                  .bodyMedium,
                              maxLines: 1,
                            )
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () => renameFolder(context, widget.folder),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => deleteFolder(context, widget.folder),
                      ),
                    ],
                  ),
                  _isExpaned
                      ? Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: Theme
                          .of(context)
                          .hoverColor,
                    ),
                    child: ReorderableListView.builder(
                        itemCount: widget.folder.contents.length,
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        onReorder: (oldIndex, newIndex) {
                          final fitting = widget.folder.contents[oldIndex];
                          if (oldIndex < newIndex) {
                            // removing the item at oldIndex will shorten the list by 1.
                            // https://api.flutter.dev/flutter/widgets/ReorderCallback.html
                            newIndex -= 1;
                          }

                          context.read<ShipFittingBrowserBloc>().add(
                            ReorderShipFitting(
                                element: fitting,
                                newIndex: newIndex,
                                folder: widget.folder
                            ),
                          );
                        },
                        itemBuilder: (context, index) {
                          var loadout = widget.folder.contents[index];
                          if (loadout is ShipFittingLoadout) {
                            return ShipFittingCard(
                              key: Key(loadout.getId()),
                              loadout: loadout,
                              onTap: widget.onLoadoutTap,
                            );
                          } else if (loadout is ShipFittingFolder) {
                            return FittingFolderCard(
                                key: Key(loadout.getId()),
                                folder: loadout,
                                onLoadoutTap: widget.onLoadoutTap);
                          } else {
                            return Text(
                                "Error, unknown element: ${loadout.getId()}\n${loadout.getName()}");
                          }
                        }),
                  )
                      : Container()
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _toggleFolder() {
    setState(() {
      _isExpaned = !_isExpaned;
    });
  }

  Future<void> renameFolder(BuildContext widgetContext,
      ShipFittingFolder folder) {
    final folderController = TextEditingController(text: folder.name);
    return showDialog<void>(
      context: widgetContext,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(StaticLocalisationStrings.renameFolder),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Please enter the new name of the folder\n'),
                TextField(
                  controller: folderController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'New Folder Name',
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
                widgetContext
                    .read<ShipFittingBrowserBloc>()
                    .add(RenameFittingFolder(
                    folder: widget.folder, newName: folderController.text));
                Navigator.of(context).pop();
              },
              child: LocalisedText(localiseId: LocalisationStrings.ok),
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteFolder(
      BuildContext widgetContext, ShipFittingFolder folder) {
    //ToDo: Merge with deleteFolder in ship_fitting_card.dart?
    return showDialog<void>(
      context: widgetContext,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(StaticLocalisationStrings.deleteFolder),
          content: Text(
              'Are you sure you want to delete this folder? This will include ALL of it\'s contents!'
                  '\n\nThis action cannot be reversed.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: LocalisedText(
                localiseId: LocalisationStrings.cancel,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: TextButton(
                onPressed: () {
                  widgetContext
                      .read<ShipFittingBrowserBloc>()
                      .add(DeleteShipFitting(shipFittingId: folder.id));
                  Navigator.of(context).pop();
                },
                child: LocalisedText(localiseId: LocalisationStrings.ok),
              ),
            ),
          ],
        );
      },
    );
  }
}
