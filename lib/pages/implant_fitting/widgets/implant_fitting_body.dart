import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sweet/mixins/fitting_item_details_mixin.dart';
import 'package:sweet/model/implant/implant_handler.dart';
import 'package:sweet/pages/implant_fitting/bloc/implant_fitting_bloc/bloc.dart';
import 'package:sweet/pages/implant_fitting/bloc/implant_fitting_bloc/states.dart';
import 'package:sweet/pages/ship_fitting/widgets/ship_fitting_context_drawer.dart';
import 'package:sweet/repository/implant_fitting_loadout_repository.dart';

import '../../../database/entities/item.dart';
import '../../../database/entities/market_group.dart';
import '../../../model/fitting/fitting_implant_module.dart';
import '../../../model/implant/slot_type.dart';
import '../../../repository/item_repository.dart';
import '../bloc/implant_fitting_bloc/events.dart';
import 'implant_slot_list_view.dart';

class ImplantFittingBody extends StatefulWidget {
  @override
  State<ImplantFittingBody> createState() => _ImplantFittingBodyState();
}

class _ImplantFittingBodyState extends State<ImplantFittingBody>
    with FittingItemDetailsMixin {
  @override
  Widget build(BuildContext context) {
    var fitting = Provider.of<ImplantHandler>(context);
    return BlocListener<ImplantFittingBloc, ImplantFittingState>(
      listener: (context, state) {
        _handleFittingState(state, context);
      },
      child: LayoutBuilder(builder: (context, constraints) {
        return _buildNarrowLayout(fitting, context);
      }),
    );
  }

  Future<void> _handleFittingState(
      ImplantFittingState state, BuildContext context) async {
    if (state is OpenContextDrawerState) {
      final selectedItem = await showMarketGroupDrawer(
          context,
          state.topGroup,
          state.initialItems,
          null
      );

      await _handleDrawerSelection(
        selectedItem,
        state.slotIndex,
      );
    }
  }

  Widget _buildNarrowLayout(ImplantHandler implant, BuildContext context) {
    return Column(
      verticalDirection: VerticalDirection.down,
      children: [
        Expanded(
          child: ImplantSlotListView(
              implant: implant,
              onTap: ({required ImplantSlotType type, required int index, List<int>? allowedItems}) =>
              context.read<ImplantFittingBloc>().add(
                ShowFittingsMenu(slotType: type, slotIndex: index, allowedItemIds: allowedItems),
              ),
          ),
        ),// ShipFittingToolbar(),
      ],
    );
  }

  Future<Item?> showMarketGroupDrawer(
      BuildContext context,
      MarketGroup? topGroup,
      List<Item>? initialItems,
      List<int>? blacklistItems,
      ) async {
    return await showModalBottomSheet<Item>(
      context: context,
      elevation: 16,
      builder: (context) => ShipFittingContextDrawer(
        marketGroup: topGroup,
        initialFilteredItems: initialItems,
        blacklistItems: blacklistItems,
      ),
    );
  }

  Future<void> _handleDrawerSelection(
      Item? item,
      int slotIndex,
      ) async {
    if (item != null) {
      final fitting = Provider.of<ImplantHandler>(context, listen: false);
      final itemRepo = RepositoryProvider.of<ItemRepository>(context);

      final FittingImplantModule module = await itemRepo.implantModule(
          id: item.id);

      fitting.fitItem(
        module, slotIndex: slotIndex
      );
      await RepositoryProvider.of<ImplantFittingLoadoutRepository>(context)
          .saveImplants();
      print("Fitted item to implant slot $slotIndex!");
    }
  }
}
