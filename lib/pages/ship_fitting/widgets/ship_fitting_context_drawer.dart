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
    // ToDo: This is still not correct, not all items have a fixed localization
    //       string in the db, but are using composed names that can't be
    //       handled by an SQL query alone.
    filterString = filterString.trim();
    if (filterString.isEmpty) {
      setState(() {
        _filteredItems = [];
      });
      return;
    }

    // The items we want to filter. This assumes the market groups, or its
    // children, are already loaded with items.
    Iterable<Item> baseItems;

    // The market groups to search in, to narrow down the search.
    final List<int> marketGroupIds = [widget.marketGroup.id];
    if (widget.marketGroup == MarketGroup.invalid) {
      for (var item in widget.initialItems) {
        final marketGroupId = item.marketGroupId;
        if (marketGroupId == null) {
          continue;
        }
        final topGroup = marketGroupId * 100000;
        if (!marketGroupIds.contains(topGroup)) {
          marketGroupIds.add(topGroup);
        }
      }
      baseItems = widget.initialItems;
    } else {
      if (!widget.marketGroup.isValid) {
        // Pseudo-Market group, used in the fitting list to combine ships and
        // structures. Is a bit confusing with MarketGroup.invalid...
        for (var child in widget.marketGroup.children) {
          marketGroupIds.add(child.id);
        }
      }
      baseItems = widget.marketGroup.getAllItemsRecursive();
    }
    final itemRepository = RepositoryProvider.of<ItemRepository>(context);

    final itemIds = Set<int>.from(await itemRepository.itemsFilteredOnNameAndMarketGroups(
      filter: filterString.toLowerCase(),
      marketGroupIds: marketGroupIds,
    ));

    final items = baseItems.where((item) =>
        itemIds.contains(item.id) &&
        !widget.blacklistItems.contains(item.id));

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
