import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sweet/model/fitting/fitting_item.dart';

import 'package:sweet/model/ship/slot_type.dart';
import 'package:sweet/pages/ship_fitting/bloc/ship_fitting_bloc/ship_fitting.dart';
import 'package:sweet/service/fitting_simulator.dart';

import '../../../model/fitting/fitting_module.dart';
import 'ship_fitting_slot_tile.dart';

class ShipSlotListView extends StatelessWidget {
  final _scrollController = ScrollController();

  ShipSlotListView({
    Key? key,
    required this.fitting,
  }) : super(key: key);

  final FittingSimulator fitting;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.zero,
      itemCount: SlotType.values.length,
      itemBuilder: (context, idx) {
        var slotType = SlotType.values[idx];

        final Iterable<FittingModule> fittings;
        if (slotType == SlotType.implantSlots) {
          fittings = [fitting.implant ?? FittingModule.empty];
        } else {
          fittings = fitting.modules(slotType: slotType);
        }

        return slotType == SlotType.implantSlots || fittings.isNotEmpty
            ? ShipFittingSlotTile(
                slotType: slotType,
                fittings: fittings,
                onTap: ({required slot, index}) =>
                    context.read<ShipFittingBloc>().add(
                          ShowFittingsMenu(slotType: slot, slotIndex: index),
                        ),
              )
            : Container();

      },
    );
  }
}
