import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sweet/model/fitting/fitting_implant.dart';
import 'package:sweet/model/fitting/fitting_module.dart';
import 'package:sweet/model/items/eve_echoes_categories.dart';
import 'package:sweet/model/ship/eve_echoes_attribute.dart';
import 'package:sweet/service/fitting_simulator.dart';
import 'package:sweet/model/ship/slot_type.dart';

import 'character_attribute_value.dart';
import 'module_tiles/fitting_module_tile.dart';

typedef ShipFittingSlotCallback = void Function(
    {required SlotType slot, int? index});

class ShipFittingSlotTile extends StatelessWidget {
  final SlotType slotType;
  final Iterable<FittingModule> fittings;
  final ShipFittingSlotCallback onTap;

  const ShipFittingSlotTile({
    super.key,
    required this.slotType,
    required this.fittings,
    required this.onTap,
  });

  String get slotTileTitle {
    switch (slotType) {
      case SlotType.high:
        return 'High';
      case SlotType.mid:
        return 'Mid';
      case SlotType.low:
        return 'Low';
      case SlotType.combatRig:
        return 'Combat Rigs';
      case SlotType.engineeringRig:
        return 'Engineering Rigs';
      case SlotType.drone:
        return 'Drones';
      case SlotType.nanocore:
        return 'Nanocore';
      case SlotType.lightFFSlot:
        return 'Lightweight Frigates';
      case SlotType.lightDDSlot:
        return 'Lightweight Destroyers';
      case SlotType.lightCASlot:
        return 'Lightweight Cruisers';
      case SlotType.lightBCSlot:
        return 'Lightweight Battlecruisers';
      case SlotType.hangarRigSlots:
        return 'Hangar Modules';
      case SlotType.implantSlots:
        return 'Implants'; // Implants may not be fitted normally
    }
  }

  Widget slotTileSubtitle(BuildContext context) {
    switch (slotType) {
      case SlotType.drone:
        final hasFighters =
            fittings.any((e) => e.groupId == EveEchoesGroup.fighters.groupId);
        return Row(children: [
          CharacterAttributeValue(
            attribute: hasFighters
                ? EveEchoesAttribute.fighterControlDistance
                : EveEchoesAttribute.droneControlRange,
            formulaOverride: (value) => value / 1000,
            unitOverride: 'km',
            useSpacer: false,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Spacer()
        ]);

      default:
        return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    final showButtons = fittings.length > 1 &&
        slotType != SlotType.nanocore &&
        slotType != SlotType.implantSlots;
    final String count;
    if (slotType == SlotType.implantSlots) {
      final hasActiveImplant = fittings
          .whereType<ImplantFitting>()
          .any((e) => !(e).isPassive);
      final passiveCount = fittings
          .whereType<ImplantFitting>()
          .where((e) => (e).isPassive).length;
      count = '${hasActiveImplant ? 1 : 0} active, $passiveCount passive';
    } else {
      count = '${fittings.where((m) => m.isValid).length}/${fittings.length}';
    }
    return ExpansionTile(
      title: Row(
        children: [
          Text(slotTileTitle),
          Spacer(),
          Text(
            count,
          ),
        ],
      ),
      subtitle: slotTileSubtitle(context),
      children: [
        showButtons
            ? Row(
                children: [
                  Expanded(
                    child: Card(
                      child: InkWell(
                        onTap: () => onTap(slot: slotType),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Fit all slots',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Card(
                      child: InkWell(
                        onTap: () => Provider.of<FittingSimulator>(context,
                                listen: false)
                            .fitItemIntoAll(
                          FittingModule.empty,
                          slot: slotType,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Clear all slots',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : Container(height: 0),
        ListView.builder(
          padding: EdgeInsets.only(top: showButtons ? 0 : 8, bottom: 8.0),
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: fittings.length,
          itemBuilder: (context, index) {
            final module = fittings.elementAt(index);
            return Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: FittingModuleTile(
                  module: module,
                  index: index,
                  onTap: (index) => onTap(slot: slotType, index: index),
                  onClearPressed: () =>
                      Provider.of<FittingSimulator>(context, listen: false)
                          .fitItem(
                    FittingModule.empty,
                    slot: slotType,
                    index: index,
                  ),
                  onStateToggle: (newState) =>
                      Provider.of<FittingSimulator>(context, listen: false)
                          .setModuleState(
                    newState,
                    slot: slotType,
                    index: index,
                  ),
                  onClonePressed: (int index) =>
                      Provider.of<FittingSimulator>(context, listen: false)
                          .cloneFittedItem(
                    slot: slotType,
                    index: index,
                  ),
                ),
              ),
            );
          },
        )
      ],
    );
  }
}
