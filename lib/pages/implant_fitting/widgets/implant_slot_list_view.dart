import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sweet/model/fitting/fitting_implant_module.dart';
import 'package:sweet/model/implant/implant_handler.dart';
import 'package:sweet/model/implant/slot_type.dart';

import 'implant_module_tile.dart';

typedef ImplantFittingSlotCallback = void Function(
    {required ImplantSlotType type,
    required int index,
    List<int>? allowedItems});

class ImplantSlotListView extends StatelessWidget {
  final _scrollController = ScrollController();
  final ImplantFittingSlotCallback onTap;

  ImplantSlotListView({
    Key? key,
    required this.implant,
    required this.onTap,
  }) : super(key: key);

  final ImplantHandler implant;

  @override
  Widget build(BuildContext context) {
    // print("Building list for ${implant.slotCount} slots");
    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.zero,
      itemCount: implant.slotCount,
      itemBuilder: (context, idx) {
        var module = implant.getModuleByIndex(idx)!;
        final limitations = implant.getLimitationsByIndex(idx);

        String slotName = "N/A";
        switch (module.slot) {
          case ImplantSlotType.common:
            slotName = "General Unit";
            break;
          case ImplantSlotType.slaveCommon:
            slotName = "Reactive Unit";
            break;
          case ImplantSlotType.branch:
            slotName = "Branch";
            break;
          case ImplantSlotType.upgrade:
            slotName = "Upgrade";
            break;
          case ImplantSlotType.disabled:
            slotName = "Disabled";
            break;
          default:
            slotName = "N/A";
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    "Level ${module.level} - $slotName",
                  ),
                ),
              ),
              Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ImplantModuleTile(
                      module: module,
                      implant: implant,
                      index: idx,
                      onTap: (index) => onTap(
                          type: module.slot,
                          index: index,
                          allowedItems: limitations),
                      onClearPressed: () =>
                          Provider.of<ImplantHandler>(context, listen: false)
                              .fitItem(
                                  FittingImplantModule.getEmpty(module.slot),
                                  slotIndex: idx),
                      onStateToggle: (newState) {},
                      onClonePressed: (int index) {},
                    ),
                  )),
            ],
          ),
        );
      },
    );
  }
}
