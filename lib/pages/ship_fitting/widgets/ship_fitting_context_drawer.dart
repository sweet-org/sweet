import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sweet/util/localisation_constants.dart';

import '../../../database/entities/market_group.dart';
import '../../../repository/item_repository.dart';
import '../../market_browser/market_browser.dart';
import '../../../database/entities/item.dart';
import '../../../widgets/search_bar.dart';

class ShipFittingContextDrawer extends StatefulWidget {
  final MarketGroup marketGroup;
  final List<Item> initialItems;
  final List<int> blacklistItems;

  ShipFittingContextDrawer({
    super.key,
    MarketGroup? marketGroup,
    List<Item>? initialFilteredItems,
    List<int>? blacklistItems,
  })  : assert(marketGroup != null || initialFilteredItems != null),
        marketGroup = marketGroup ?? MarketGroup.invalid,
        initialItems = initialFilteredItems ?? [],
        blacklistItems = blacklistItems ?? List<int>.empty();

  @override
  State<ShipFittingContextDrawer> createState() =>
      _ShipFittingContextDrawerState(initialItems);
}

class _ShipFittingContextDrawerState extends State<ShipFittingContextDrawer> {
  var _filteredItems = <Item>[];

  _ShipFittingContextDrawerState(List<Item> initialItems) {
    _filteredItems = initialItems;
  }

  Future<void> _filterItems(String filterString) async {
    Iterable<Item> items = widget.initialItems;
    if (widget.marketGroup == MarketGroup.invalid) {
      // TODO: Add in proper filtering here
      // As we really need the item name to be with the item
      items = widget.initialItems;
    } else {
      final itemRepository = RepositoryProvider.of<ItemRepository>(context);
      items = await itemRepository.itemsFilteredOnNameAndMarketGroup(
        filter: filterString.toLowerCase(),
        marketGroupId: widget.marketGroup.id,
      );
    }

    setState(() {
      _filteredItems = items.toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    var showMarket = _filteredItems.isEmpty;
    final showSearch = widget.marketGroup != MarketGroup.invalid;
    return Container(
      height: 600,
      color: Theme.of(context).canvasColor,
      child: Column(
        children: [
          showSearch
              ? SweetSearchBar(
                  onSubmit: _filterItems,
                  triggerOnChange: true,
                )
              : Container(),
          Expanded(
            child: showMarket ? _buildMarketTiles() : _buildFilteredItems(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilteredItems() {
    if (_filteredItems.isEmpty) {
      return Center(
        child: Text(StaticLocalisationStrings.noResultsFound),
      );
    }

    var sorted = _filteredItems;
    sorted.sort((a, b) => a.id < b.id ? -1 : 1);
    return ListView.builder(
      itemCount: sorted.length,
      itemBuilder: (context, firstLevelindex) {
        var item = sorted[firstLevelindex];

        return ItemListTile(
          item: item,
          onSelected: (item) => Navigator.pop(context, item),
        );
      },
    );
  }

  Widget _buildMarketTiles() {
    var sorted = widget.marketGroup.children;
    sorted.sort((a, b) => a.id < b.id ? -1 : 1);
    return ListView.builder(
      itemCount: sorted.length,
      itemBuilder: (context, firstLevelindex) {
        var child = sorted[firstLevelindex];

        return MarketGroupTile(
          marketGroup: child,
          onItemSelected: (item) => Navigator.pop(context, item),
          blacklistItems: widget.blacklistItems,
        );
      },
    );
  }
}
