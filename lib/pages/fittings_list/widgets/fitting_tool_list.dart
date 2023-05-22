import 'package:flutter/services.dart';
import 'package:sweet/bloc/item_repository_bloc/market_group_filters.dart';
import 'package:sweet/database/entities/item.dart';
import 'package:sweet/mixins/scan_qrcode_mixin.dart';
import 'package:sweet/model/items/eve_echoes_categories.dart';
import 'package:sweet/repository/character_repository.dart';
import 'package:sweet/service/fitting_simulator.dart';
import 'package:sweet/model/ship/ship_fitting_loadout.dart';
import 'package:sweet/pages/fittings_list/bloc/ship_fitting_browser_bloc/ship_fitting_browser_bloc.dart';
import 'package:sweet/pages/fittings_list/widgets/ship_fitting_card.dart';
import 'package:sweet/pages/ship_fitting/ship_fitting_page.dart';
import 'package:sweet/pages/ship_fitting/widgets/ship_fitting_context_drawer.dart';
import 'package:sweet/repository/item_repository.dart';
import 'package:sweet/service/attribute_calculator_service.dart';
import 'package:sweet/util/localisation_constants.dart';
import 'package:sweet/util/platform_helper.dart';
import 'package:sweet/widgets/speed_dial_fab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FittingToolList extends StatefulWidget {
  @override
  State<FittingToolList> createState() => _FittingToolListState();
}

class _FittingToolListState extends State<FittingToolList>
    with ScanQrCode, RouteAware {
  var showLoader = false;

  void showShipList(BuildContext context) async {
    var shipsMarketGroup = RepositoryProvider.of<ItemRepository>(context)
        .marketGroupMap[MarketGroupFilters.ship.marketGroupId];

    if (shipsMarketGroup == null) return;

    var ship = await showModalBottomSheet<Item?>(
      context: context,
      elevation: 16,
      builder: (context) => ShipFittingContextDrawer(
        marketGroup: shipsMarketGroup,
      ),
    );

    if (ship == null || ship.categoryId != EveEchoesCategory.ships.categoryId) {
      if (ship != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(StaticLocalisationStrings.itemIsNotShip),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    var itemRepo = RepositoryProvider.of<ItemRepository>(context);

    final loadout = ShipFittingLoadout.fromShip(
      ship.id,
      await itemRepo.getShipLoadoutDefinition(ship.id),
    );

    await _showFittingPage(loadout);
  }

  Future<void> _showFittingPage(ShipFittingLoadout loadout) async {
    setState(() {
      showLoader = true;
    });

    final itemRepo = RepositoryProvider.of<ItemRepository>(context);
    final attrCalc = RepositoryProvider.of<AttributeCalculatorService>(context);
    final charRepo = RepositoryProvider.of<CharacterRepository>(context);
    final fitting = await FittingSimulator.fromShipLoadout(
      attributeCalculatorService: attrCalc,
      itemRepository: itemRepo,
      ship: await itemRepo.ship(id: loadout.shipItemId),
      loadout: loadout,
      pilot: charRepo.defaultPilot,
    );

    setState(() {
      showLoader = false;
    });

    await Navigator.pushNamed(
      context,
      ShipFittingPage.routeName,
      arguments: fitting,
    );

    context.read<ShipFittingBrowserBloc>().add(
          LoadAllShipFittings(),
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
          BlocBuilder<ShipFittingBrowserBloc, ShipFittingBrowserState>(
              builder: (context, state) {
            if (state is ShipFittingBrowserLoaded) {
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

                    context.read<ShipFittingBrowserBloc>().add(
                          ReorderShipFitting(
                              shipFitting: fitting, newIndex: newIndex),
                        );
                  },
                  itemBuilder: (context, index) {
                    var loadout = list[index];
                    return ShipFittingCard(
                      key: Key(loadout.id),
                      loadout: loadout,
                      onTap: _showFittingPage,
                    );
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
    return SpeedDialFab(
      buttonClosedColor: Theme.of(context).primaryColor,
      children: [
        SizedBox.fromSize(
          size: Size.square(48),
          child: RawMaterialButton(
            onPressed: () => showShipList(context),
            fillColor: Theme.of(context).primaryColor,
            shape: CircleBorder(),
            child: Icon(
              Icons.add,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox.fromSize(
          size: Size.square(48),
          child: RawMaterialButton(
            onPressed: () => fittingFromClipboard(context),
            fillColor: Theme.of(context).primaryColor,
            shape: CircleBorder(),
            child: Icon(
              Icons.content_paste,
              color: Colors.white,
            ),
          ),
        ),
        PlatformHelper.isMobile
            ? SizedBox.fromSize(
                size: Size.square(48),
                child: RawMaterialButton(
                  onPressed: () => fittingFromQrCode(context),
                  fillColor: Theme.of(context).primaryColor,
                  shape: CircleBorder(),
                  child: Center(
                      child: Icon(
                    Icons.qr_code_scanner,
                    color: Colors.white,
                  )),
                ),
              )
            : Container(
                width: 1,
                height: 1,
              ),
      ],
    );
  }

  Container _buildEmptyState() {
    return Container(
      child: Center(
        child: Text(
          'No ship fittings found.\nMake some!',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Future<void> fittingFromClipboard(BuildContext context) async {
    final data = await Clipboard.getData('text/plain');

    await addFittingFromString(data?.text, context);
  }

  void fittingFromQrCode(BuildContext context) {
    scanQrCode(
      context: context,
      onScan: (data) => addFittingFromString(data, context),
    );
  }

  Future<void> addFittingFromString(String? data, BuildContext context) async {
    if (data != null) {
      try {
        final fitting = ShipFittingLoadout.fromQrCodeData(data);
        context.read<ShipFittingBrowserBloc>().add(
              ImportShipFitting(shipFitting: fitting),
            );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(StaticLocalisationStrings.fittingAdded),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
