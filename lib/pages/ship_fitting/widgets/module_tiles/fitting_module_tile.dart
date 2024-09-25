import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:sweet/mixins/fitting_item_details_mixin.dart';
import 'package:sweet/model/fitting/fitting_drone.dart';
import 'package:sweet/model/fitting/fitting_implant.dart';
import 'package:sweet/model/fitting/fitting_implant_module.dart';

import 'package:sweet/model/fitting/fitting_module.dart';
import 'package:sweet/model/fitting/fitting_rig_integrator.dart';
import 'package:sweet/model/ship/slot_type.dart';
import 'package:sweet/pages/ship_fitting/widgets/module_state_toggle.dart';
import 'package:sweet/pages/ship_fitting/widgets/module_tiles/fitting_drone_tile_details.dart';
import 'package:sweet/pages/ship_fitting/widgets/module_tiles/fitting_rig_integrator_tile_details.dart';
import 'package:sweet/repository/item_repository.dart';
import 'package:sweet/service/fitting_simulator.dart';
import 'package:sweet/util/localisation_constants.dart';
import 'package:sweet/widgets/localised_text.dart';

import 'fitting_implant_tile_details.dart';
import 'fitting_module_tile_details.dart';
import 'fitting_nanocore_tile_details.dart';

typedef FittingModuleTileTapCallback = void Function(int index);
typedef ModuleCloneCallback = void Function(int index);

class FittingModuleTile extends StatelessWidget with FittingItemDetailsMixin {
  final int index;
  final FittingModule module;
  final FittingModuleTileTapCallback onTap;
  final VoidCallback onClearPressed;
  final ModuleCloneCallback onClonePressed;
  final ModuleStateToggleCallback onStateToggle;

  const FittingModuleTile({
    Key? key,
    required this.index,
    required this.module,
    required this.onTap,
    required this.onClearPressed,
    required this.onClonePressed,
    required this.onStateToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: () => onTap(index),
        child: _buildContent(context: context),
      );

  Widget _buildContent({required BuildContext context}) {
    var fitting = Provider.of<FittingSimulator>(context, listen: false);

    if (!module.isValid) {
      return Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child: (AutoSizeText(StaticLocalisationStrings.emptyModule)),
        ),
      );
    }

    final handler = module is ImplantFitting
        ? fitting.getImplantHandler(module as ImplantFitting)
        : null;
    var extraText = "";
    if (handler != null) {
      extraText = " (Lvl. ${(module as ImplantFitting).trainedLevel})";
      if (handler.isPassive) {
        extraText += " (Passive)";
      }
    }

    return Column(children: [
      Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Row(
          children: [
            module.canActivate
                ? Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ModuleStateToggle(
                      onToggle: onStateToggle,
                      state: module.state,
                    ),
                  )
                : Container(),
            Expanded(
              child: Row(
                children: [
                  LocalisedText(
                    item: module.item,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  extraText != "" ? Text(extraText) : Container()
                ],
              ),
            ),
            IconButton(
              padding: EdgeInsets.zero,
              constraints: BoxConstraints.tight(Size.square(32)),
              icon: Icon(
                Icons.info,
              ),
              onPressed: () => showItemDetails(
                module: module,
                itemRepository: RepositoryProvider.of<ItemRepository>(context),
                context: context,
              ),
            ),
          ],
        ),
      ),
      _buildModuleWidgets(
        fitting: fitting,
        context: context,
      ),
      Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Spacer(),
            IconButton(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              constraints: BoxConstraints.tight(Size.square(32)),
              icon: Icon(Icons.copy),
              onPressed: () => onClonePressed(index),
            ),
            IconButton(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              constraints: BoxConstraints.tight(Size.square(32)),
              icon: Icon(Icons.delete),
              onPressed: onClearPressed,
            ),
          ],
        ),
      )
    ]);
  }

  Widget _buildModuleWidgets({
    required FittingSimulator fitting,
    required BuildContext context,
  }) {
    if (module.slot == SlotType.nanocore) {
      return FittingNanocoreTileDetails(
        module: module,
        fitting: fitting,
      );
    } else if (module is FittingRigIntegrator) {
      return FittingRigIntegratorTileDetails(
        integrator: module as FittingRigIntegrator,
        fitting: fitting,
      );
    } else if (module is FittingDrone) {
      return FittingDroneTileDetails(
        drone: module as FittingDrone,
        fitting: fitting,
      );
    } else if (module is ImplantFitting) {
      return FittingImplantTileDetails(
        implant: module as ImplantFitting,
        fitting: fitting,
        onStateToggle: (implantNumber, slotId, newState) =>
            Provider.of<FittingSimulator>(context, listen: false)
                .setImplantModuleState(newState,
                    slotIndex: implantNumber, implantSlotId: slotId),
      );
    } else {
      return FittingModuleTileDetails(
        module: module,
        fitting: fitting,
      );
    }
  }
}
