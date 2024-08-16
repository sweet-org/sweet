import 'package:provider/provider.dart';
import 'package:sweet/model/implant/implant_fitting_loadout.dart';
import 'package:sweet/model/implant/implant_handler.dart';
import 'package:sweet/model/ship/ship_fitting_loadout.dart';
import 'package:sweet/repository/implant_fitting_loadout_repository.dart';
import 'package:sweet/repository/localisation_repository.dart';
import 'package:sweet/repository/ship_fitting_repository.dart';
import 'package:sweet/service/fitting_simulator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sweet/util/localisation_constants.dart';
import 'package:sweet/widgets/localised_text.dart';

import '../bloc/implant_fitting_bloc/bloc.dart';
import '../bloc/implant_fitting_bloc/events.dart';

class ImplantFittingHeader extends StatefulWidget {
  @override
  State<ImplantFittingHeader> createState() => _ShipFittingHeaderState();
}

class _ShipFittingHeaderState extends State<ImplantFittingHeader> {
  bool editMode = false;

  final _formKey = GlobalKey<FormState>();

  String? _name;

  void toggleEdit(ImplantHandler fitting) {
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

  Future<void> saveFitting(ImplantHandler fitting) async {
    RepositoryProvider.of<ImplantFittingBloc>(context).add(
      SaveImplantFitting(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ImplantHandler>(builder: (context, fitting, widget) {
      final implant = fitting.implant;
      var implantName = RepositoryProvider.of<LocalisationRepository>(context)
          .getLocalisedNameForItem(implant.item);

      return Material(
        elevation: 5,
        color: Theme.of(context).primaryColor,
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
                              color: Colors.white,
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
                                IconButton(
                                  icon: Icon(
                                    editMode ? Icons.done : Icons.edit,
                                    color: Colors.white,
                                  ),
                                  onPressed: () => toggleEdit(fitting),
                                ),
                                editMode
                                    ? Container()
                                    : IconButton(
                                  icon: Icon(
                                    Icons.save,
                                    color: Colors.white,
                                  ),
                                  onPressed: () => saveFitting(fitting),
                                ),
                              ],
                            ),
                            editMode
                                ? _buildFittingDetailsForm(fitting)
                                : _buildFittingDetails(fitting),
                            Text(
                              implantName,
                              style: TextStyle(
                                color: Colors.white.withAlpha(96),
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
            ],
          ),
        ),
      );
    });
  }

  Form _buildFittingDetailsForm(ImplantHandler fitting) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          TextFormField(
            initialValue: fitting.name,
            cursorColor: Colors.white,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Enter Name',
              hintText: 'Name',
              labelStyle: TextStyle(color: Colors.white.withAlpha(150)),
              hintStyle: TextStyle(color: Colors.white.withAlpha(150)),
              fillColor: Colors.white,
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

  Widget _buildFittingDetails(ImplantHandler fitting) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          fitting.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 30,
          ),
        ),
      ],
    );
  }

  void shouldPopPage(
    BuildContext widgetContext, {
    required ImplantFittingLoadout loadout,
  }) async {
    final fittingRepo =
        RepositoryProvider.of<ImplantFittingLoadoutRepository>(widgetContext);

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
}
