import 'package:sweet/bloc/item_repository_bloc/market_group_filters.dart';
import 'package:sweet/database/entities/item.dart';
import 'package:sweet/mixins/scan_qrcode_mixin.dart';
import 'package:sweet/model/implant/implant_handler.dart';
import 'package:sweet/model/implant/implant_loadout_definition.dart';
import 'package:sweet/model/items/eve_echoes_categories.dart';
import 'package:sweet/pages/implants_list/bloc/events.dart';
import 'package:sweet/pages/ship_fitting/widgets/ship_fitting_context_drawer.dart';
import 'package:sweet/repository/item_repository.dart';
import 'package:sweet/widgets/speed_dial_fab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:sweet/model/implant/implant_fitting_loadout.dart';
import 'package:sweet/pages/implant_fitting/implant_fitting_page.dart';
import 'package:sweet/pages/implants_list/bloc/bloc.dart';
import 'package:sweet/pages/implants_list/bloc/states.dart';
import 'implant_fitting_card.dart';

class ImplantList extends StatefulWidget {
  @override
  State<ImplantList> createState() => _ImplantListState();
}

class _ImplantListState extends State<ImplantList> with ScanQrCode, RouteAware {
  var showLoader = false;

  void showImplantList(BuildContext context) async {
    var implantsMarketGroup = RepositoryProvider.of<ItemRepository>(context)
        .marketGroupMap[MarketGroupFilters.advancedImplants.marketGroupId];
    if (implantsMarketGroup == null) return;

    var implant = await showModalBottomSheet<Item?>(
      context: context,
      elevation: 16,
      builder: (context) => ShipFittingContextDrawer(
        marketGroup: implantsMarketGroup,
      ),
    );

    if (implant == null ||
        implant.categoryId != EveEchoesCategory.implant.categoryId) {
      if (implant != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("This item is not an implant"),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    var itemRepo = RepositoryProvider.of<ItemRepository>(context);
    final definition = await itemRepo.getImplantLoadoutDefinition(implant.id);

    final loadout = ImplantFittingLoadout.fromDefinition(
      implant.id,
      definition,
    );

    await _showFittingPage(loadout, definition: definition);
  }

  Future<void> _showFittingPage(ImplantFittingLoadout loadout,
      {ImplantLoadoutDefinition? definition}) async {
    setState(() {
      showLoader = true;
    });

    final itemRepo = RepositoryProvider.of<ItemRepository>(context);
    final fitting = await ImplantHandler.fromImplantLoadout(
      implant: await itemRepo.implantModule(id: loadout.implantItemId),
      itemRepository: itemRepo,
      definition: definition ??
          await itemRepo.getImplantLoadoutDefinition(loadout.implantItemId),
      loadout: loadout,
    );

    setState(() {
      showLoader = false;
    });

    await Navigator.pushNamed(
      context,
      ImplantFittingPage.routeName,
      arguments: fitting,
    );

    context.read<ImplantFittingBrowserBloc>().add(
          LoadAllImplantFittings(),
        );
  }

  @override
  void didPush() {
    setState(() {
      showLoader = false;
    });
    super.didPush();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: _buildFab(context),
      body: Stack(
        children: [
          BlocBuilder<ImplantFittingBrowserBloc, ImplantFittingBrowserState>(
              builder: (context, state) {
            if (state is ImplantFittingBrowserLoaded) {
              var list = state.fittings.toList();

              if (list.isEmpty) {
                return _buildEmptyState();
              } else {
                return ReorderableListView.builder(
                  padding: EdgeInsets.only(bottom: 56),
                  itemCount: list.length,
                  onReorder: (oldIndex, newIndex) {
                    final fitting = list[oldIndex];
                    if (oldIndex < newIndex) {
                      // removing the item at oldIndex will shorten the list by 1.
                      // https://api.flutter.dev/flutter/widgets/ReorderCallback.html
                      newIndex -= 1;
                    }
                    context.read<ImplantFittingBrowserBloc>().add(
                          ReorderImplantFitting(
                              element: fitting, newIndex: newIndex),
                        );
                  },
                  itemBuilder: (context, index) {
                    var loadout = list[index];
                    return ImplantFittingCard(
                        key: Key(loadout.getId()),
                        loadout: loadout,
                        onTap: _showFittingPage);
                  },
                );
              }
            }

            return Center(
              child: CircularProgressIndicator(),
            );
          }),
          showLoader
              ? Container(
                  color: Colors.black.withAlpha(128),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }

  SpeedDialFab _buildFab(BuildContext context) {
    final colorBg = Theme.of(context).colorScheme.secondary;
    final colorOnBg = Theme.of(context).colorScheme.onSecondary;
    return SpeedDialFab(
      children: [
        SizedBox.fromSize(
          size: Size.square(48),
          child: RawMaterialButton(
            onPressed: () => showImplantList(context),
            fillColor: colorBg,
            shape: CircleBorder(),
            child: Icon(
              Icons.add,
              color: colorOnBg,
            ),
          ),
        ),
        // ToDo: Implement clipboard and QR-Code for implants
      ],
    );
  }

  Container _buildEmptyState() {
    return Container(
      child: Center(
        child: Text(
          'No implant fittings found.\nMake some!',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
