import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sweet/repository/item_repository.dart';
import 'package:sweet/util/localisation_constants.dart';
import 'package:sweet/util/sweet_icons.dart';
import 'package:sweet/widgets/localised_text.dart';

import 'package:sweet/model/implant/implant_fitting_loadout.dart';
import '../bloc/bloc.dart';
import '../bloc/events.dart';

typedef ImplantFittingLoadoutCallback = void Function(
    ImplantFittingLoadout loadout);

class ImplantFittingCard extends StatelessWidget {
  final ImplantFittingLoadout loadout;
  final ImplantFittingLoadoutCallback onTap;

  const ImplantFittingCard(
      {Key? key, required this.loadout, required this.onTap})
      : super(key: key);

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
                      SweetIcons.implant,
                      size: 48.0,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Consumer<ImplantFittingLoadout>(
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
                                  .itemName(id: loadout.implantItemId)
                                  .then((value) => value!),
                              builder: (context, snapshot) => AutoSizeText(
                                '${snapshot.data ?? 'Unknown Implant'} (Lvl. ${loadout.level})',
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
  final ImplantFittingLoadout loadout;

  const FittingControls({Key? key, required this.loadout}) : super(key: key);

  @override
  State<FittingControls> createState() => _FittingControlsState();
}

class _FittingControlsState extends State<FittingControls> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: Icon(Icons.delete),
          onPressed: () => deleteLoadout(context, widget.loadout),
        ),
      ],
    );
  }

  void _toggleControls() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  Future<void> deleteLoadout(
      BuildContext widgetContext, ImplantFittingLoadout loadout) {
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
                    .read<ImplantFittingBrowserBloc>()
                    .add(DeleteImplantFitting(implantFittingId: loadout.id));
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
