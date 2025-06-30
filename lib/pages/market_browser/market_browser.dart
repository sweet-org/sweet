import 'package:sweet/bloc/item_repository_bloc/item_repository.dart';
import 'package:sweet/database/entities/item.dart';
import 'package:sweet/database/entities/market_group.dart';
import 'package:sweet/pages/item_details/item_details_page.dart';
import 'package:sweet/repository/localisation_repository.dart';
import 'package:sweet/util/localisation_constants.dart';
import 'package:sweet/widgets/localised_text.dart';
import 'package:sweet/widgets/search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MarketBrowser extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ItemRepositoryBloc, ItemRepositoryState>(
      builder: (context, state) {
        if (state is FilteredMarketGroups) {
          var marketGroups = state.filteredMarketGroups.toList();
          return Column(
            children: [
              SweetSearchBar(
                onSubmit: (filterString) => context
                    .read<ItemRepositoryBloc>()
                    .add(FilterMarketGroups(filterString)),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: marketGroups.length,
                  itemBuilder: (context, firstLevelindex) {
                    var marketGroup = marketGroups[firstLevelindex];

                    return MarketGroupTile(
                      marketGroup: marketGroup,
                      onItemSelected: (item) => Navigator.pushNamed(
                        context,
                        ItemDetailsPage.routeName,
                        arguments: item,
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        }

        return Center(
          child: Text(StaticLocalisationStrings.incorrectStateDetected),
        );
      },
    );
  }
}

typedef ItemCallback = void Function(Item item);

class MarketGroupTile extends StatelessWidget {
  const MarketGroupTile({
    super.key,
    required this.marketGroup,
    required this.onItemSelected,
    List<int>? blacklistItems,
    this.level = 0,
  }) : blacklistItems = blacklistItems ?? const [];

  final MarketGroup marketGroup;
  final ItemCallback onItemSelected;
  final List<int> blacklistItems;
  final int level;

  @override
  Widget build(BuildContext context) {
    var localisation = RepositoryProvider.of<LocalisationRepository>(context);
    var children = <Widget>[];
    var items = marketGroup.items ?? [];

    if (items.isNotEmpty) {
      var sorted = items;
      sorted.sort((a, b) => a.id < b.id ? -1 : 1);
      children = sorted
          .where((item) => !blacklistItems.any((itemId) => item.id == itemId))
          .map((item) => ItemListTile(
                item: item,
                onSelected: onItemSelected,
                level: level + 2,
              ))
          .toList();
    } else {
      var sorted = marketGroup.children;
      sorted.sort((a, b) => a.id < b.id ? -1 : 1);
      children = sorted
          .map((mg) => MarketGroupTile(
                marketGroup: mg,
                onItemSelected: onItemSelected,
                blacklistItems: blacklistItems,
                level: level + 1,
              ))
          .toList();
    }

    var title = localisation.getLocalisedStringForMarketGroup(marketGroup);
    return ExpansionTile(
      title: Padding(
        padding: EdgeInsets.only(left: 8.0 * level),
        child: Text(title),
      ),
      children: children,
    );
  }
}

class ItemListTile extends StatelessWidget {
  const ItemListTile({
    super.key,
    required this.item,
    required this.onSelected,
    this.level = 0,
  });

  final Item item;
  final ItemCallback onSelected;
  final int level;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onSelected(item);
      },
      child: Padding(
        padding: EdgeInsets.only(left: 8.0 * level + 8, top: 8.0, bottom: 8.0),
        child: Align(
          alignment: Alignment.centerLeft,
          child: LocalisedText(item: item),
        ),
      ),
    );
  }
}
