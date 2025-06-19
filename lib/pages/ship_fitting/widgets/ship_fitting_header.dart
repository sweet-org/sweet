import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sweet/mixins/fitting_item_details_mixin.dart';
import 'package:sweet/model/character/character.dart';
import 'package:sweet/model/implant/implant_handler.dart';
import 'package:sweet/model/ship/ship_fitting_loadout.dart';
import 'package:sweet/pages/character_profile/character_profile_page.dart';
import 'package:sweet/pages/implant_fitting/implant_fitting_page.dart';
import 'package:sweet/repository/character_repository.dart';
import 'package:sweet/repository/item_repository.dart';
import 'package:sweet/repository/ship_fitting_repository.dart';
import 'package:sweet/service/fitting_simulator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sweet/pages/ship_fitting/bloc/ship_fitting_bloc/ship_fitting.dart';
import 'package:sweet/pages/ship_fitting/widgets/power_usage_bar.dart';
import 'package:sweet/repository/localisation_repository.dart';
import 'package:sweet/util/localisation_constants.dart';
import 'package:sweet/util/sweet_icons.dart';
import 'package:sweet/widgets/localised_text.dart';
import 'package:sweet/widgets/qrcode_dialog.dart';

class ShipFittingHeader extends StatefulWidget {
  @override
  State<ShipFittingHeader> createState() => _ShipFittingHeaderState();
}

class _ShipFittingHeaderState extends State<ShipFittingHeader>
    with FittingItemDetailsMixin {
  bool editMode = false;

  final _formKey = GlobalKey<FormState>();

  String? _name;

  void toggleEdit(FittingSimulator fitting) {
    setState(() {
      if (editMode) {
        _formKey.currentState!.save();
        if (!_formKey.currentState!.validate()) {
          return;
        }

        fitting.setName(_name ?? '[NO NAME]');
        saveFitting(fitting);
      }

      editMode = !editMode;
    });
  }

  Future<void> saveFitting(FittingSimulator fitting) async {
    RepositoryProvider.of<ShipFittingBloc>(context).add(
      SaveShipFitting(),
    );
  }

  Future<void> copyFittingToClipboard(FittingSimulator fitting) async {
    final localisation = RepositoryProvider.of<LocalisationRepository>(context);
    final itemRepo = RepositoryProvider.of<ItemRepository>(context);
    final fittingString = await fitting.printFitting(
      localisation,
      itemRepo,
    );
    await Clipboard.setData(
      ClipboardData(text: fittingString),
    );
  }

  void changePilot() {
    RepositoryProvider.of<ShipFittingBloc>(context).add(
      ChangePilotForFitting(),
    );
  }

  void showPilotDetails(
    BuildContext context, {
    required Character pilot,
  }) =>
      Navigator.pushNamed(
        context,
        CharacterProfilePage.routeName,
        arguments: pilot,
      );

  showImplantDetails(
    BuildContext context, {
    required ImplantHandler implant,
  }) =>
      Navigator.pushNamed(
        context,
        ImplantFittingPage.routeName,
        arguments: implant,
      );

  void showRawAttributes() {
    RepositoryProvider.of<ShipFittingBloc>(context).add(
      ShowShipFittingStats(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FittingSimulator>(builder: (context, fitting, widget) {
      final ship = fitting.ship;
      var shipName = RepositoryProvider.of<LocalisationRepository>(context)
          .getLocalisedNameForItem(ship.item);

      var pilot = fitting.pilot.name;
      var implant = fitting.activeImplant != null ? '${fitting.activeImplant?.name} - ' : '';
      final canEditPilot = !editMode &&
          fitting.pilot.id != CharacterRepository.noSkillCharacterId &&
          fitting.pilot.id != CharacterRepository.maxSkillCharacterId;
      final canEditImplant = !editMode && fitting.implantHandler != null;

      return Material(
        elevation: 5,
        color: Theme.of(context).colorScheme.onPrimary,
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Container(
                child: Padding(
                  padding: const EdgeInsets.only(
                    right: 8,
                    bottom: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.arrow_back,
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                            ),
                            onPressed: () => shouldPopPage(context,
                                loadout: fitting.loadout),
                          ),
                        ],
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                canEditPilot
                                    ? IconButton(
                                        padding: EdgeInsets.zero,
                                        splashRadius: 14,
                                        icon: Icon(
                                          Icons.manage_accounts,
                                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                                        ),
                                        onPressed: () => showPilotDetails(
                                          context,
                                          pilot: fitting.pilot,
                                        ),
                                      )
                                    : Container(),
                                IconButton(
                                  icon: Icon(
                                    editMode ? Icons.done : Icons.edit,
                                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                                  ),
                                  onPressed: () => toggleEdit(fitting),
                                ),
                                editMode
                                    ? Container()
                                    : IconButton(
                                        icon: Icon(
                                          Icons.share,
                                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                                        ),
                                        onPressed: () =>
                                            _displayQrCode(fitting),
                                      ),
                                editMode
                                    ? Container()
                                    : IconButton(
                                        icon: Icon(
                                          Icons.save,
                                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                                        ),
                                        onPressed: () => saveFitting(fitting),
                                      ),
                                editMode
                                    ? Container()
                                    : IconButton(
                                        icon: Icon(
                                          Icons.person,
                                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                                        ),
                                        onPressed: changePilot,
                                      ),
                                canEditImplant
                                    ? IconButton(
                                        padding: EdgeInsets.zero,
                                        splashRadius: 14,
                                        icon: Icon(
                                          SweetIcons.implant,
                                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                                        ),
                                        onPressed: () => showImplantDetails(
                                          context,
                                          implant: fitting.implantHandler!,
                                        ),
                                      )
                                    : Container(),
                                IconButton(
                                  icon: Icon(
                                    Icons.info,
                                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                                  ),
                                  onPressed: () => showItemDetails(
                                    module: fitting.ship,
                                    itemRepository:
                                        RepositoryProvider.of<ItemRepository>(
                                            context),
                                    context: context,
                                  ),
                                ),
                              ],
                            ),
                            editMode
                                ? _buildFittingDetailsForm(context, fitting)
                                : _buildFittingDetails(context, fitting),
                            Text(
                              '$implant$pilot - $shipName',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimaryContainer.withAlpha(180),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              PowerUsageBar(),
            ],
          ),
        ),
      );
    });
  }

  void shouldPopPage(
    BuildContext widgetContext, {
    required ShipFittingLoadout loadout,
  }) async {
    final fittingRepo =
        RepositoryProvider.of<ShipFittingLoadoutRepository>(widgetContext);

    if (fittingRepo.containsLoadout(loadout)) {
      Navigator.pop(widgetContext);
      return;
    }

    final shouldPop = await showDialog<bool>(
          context: widgetContext,
          barrierDismissible: false, // user must tap button!
          builder: (BuildContext alertContext) {
            return AlertDialog(
              title: Text(StaticLocalisationStrings.unsavedChanges),
              content: SingleChildScrollView(
                child: Text(StaticLocalisationStrings.unsavedChangesMessage),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(alertContext).pop(false),
                  child: LocalisedText(
                    localiseId: LocalisationStrings.cancel,
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(alertContext).pop(true),
                  child: Text(StaticLocalisationStrings.discard),
                ),
              ],
            );
          },
        ) ??
        true;

    if (shouldPop) {
      Navigator.of(context).pop();
    }
  }

  Form _buildFittingDetailsForm(BuildContext context, FittingSimulator fitting) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          TextFormField(
            initialValue: fitting.name,
            cursorColor: Theme.of(context).colorScheme.onPrimaryContainer,
            style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer),
            decoration: InputDecoration(
              labelText: 'Enter Name',
              hintText: 'Name',
              labelStyle: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer.withAlpha(150)),
              hintStyle: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer.withAlpha(150)),
              fillColor: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
            validator: (value) {
              if (value!.trim().isEmpty) {
                return 'Please enter a name';
              }
              return null;
            },
            onSaved: (value) {
              setState(() {
                _name = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFittingDetails(BuildContext context, FittingSimulator fitting) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          fitting.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
            fontSize: 30,
          ),
        ),
      ],
    );
  }

  void _displayQrCode(FittingSimulator fitting) {
    var json = fitting.generateQrCodeData();
    showDialog(
        context: context,
        builder: (context) => QRCodeDialog(
              data: json,
              title: fitting.name,
              leadingAction: TextButton(
                onPressed: () => copyFittingToClipboard(fitting),
                child: Text(StaticLocalisationStrings.copyFitting),
              ),
            ));
  }
}
