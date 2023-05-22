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
  const MarketGroupTile(
      {Key? key, required this.marketGroup, required this.onItemSelected})
      : super(key: key);

  final MarketGroup marketGroup;
  final ItemCallback onItemSelected;

  @override
  Widget build(BuildContext context) {
    var localisation = RepositoryProvider.of<LocalisationRepository>(context);
    var children = <Widget>[];
    var items = marketGroup.items ?? [];

    if (items.isNotEmpty) {
      var sorted = items;
      sorted.sort((a, b) => a.id < b.id ? -1 : 1);
      children = sorted
          .map((item) => ItemListTile(item: item, onSelected: onItemSelected))
          .toList();
    } else {
      var sorted = marketGroup.children;
      sorted.sort((a, b) => a.id < b.id ? -1 : 1);
      children = sorted
          .map((mg) => MarketGroupTile(
                marketGroup: mg,
                onItemSelected: onItemSelected,
              ))
          .toList();
    }

    var title = localisation.getLocalisedStringForMarketGroup(marketGroup);
    return ExpansionTile(
      title: Text(title),
      children: children,
    );
  }
}

class ItemListTile extends StatelessWidget {
  const ItemListTile({
    Key? key,
    required this.item,
    required this.onSelected,
  }) : super(key: key);

  final Item item;
  final ItemCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onSelected(item);
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Align(
          alignment: Alignment.centerLeft,
          child: LocalisedText(item: item),
        ),
      ),
    );
  }
}
