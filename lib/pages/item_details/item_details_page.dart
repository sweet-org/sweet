import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:sprintf/sprintf.dart';
import 'package:sweet/bloc/item_repository_bloc/market_group_filters.dart';
import 'package:sweet/database/entities/item_bonus_text.dart';

import 'package:sweet/model/ship/ship_bonus.dart';
import 'package:sweet/pages/item_details/widgets/item_details_attribute_list.dart';
import 'package:sweet/pages/item_details/widgets/item_details_description.dart';

import 'package:sweet/database/entities/item.dart';
import 'package:sweet/pages/item_details/widgets/item_raw_properties_list.dart';
import 'package:sweet/repository/item_repository.dart';
import 'package:sweet/repository/localisation_repository.dart';
import 'package:sweet/util/platform_helper.dart';
import 'package:sweet/widgets/ship_bonus_widget.dart';

import 'widgets/item_details_header.dart';

class ItemDetailsPage extends StatefulWidget {
  static const routeName = '/item';
  final Item item;

  const ItemDetailsPage({super.key, required this.item});

  @override
  State<ItemDetailsPage> createState() => _ItemDetailsPageState();
}

class _ItemDetailsPageState extends State<ItemDetailsPage> {
  int _selectedIndex = 0;
  List<Widget> _widgetOptions = [];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_widgetOptions.isEmpty) {
      _widgetOptions = [
        ItemDetailsWidget(
          item: widget.item,
        ),
        PlatformHelper.isDebug
            ? ItemRawPropertiesList(
                item: widget.item,
              )
            : Container(),
        ItemDetailAttributesList(
          item: widget.item,
        ),
      ];
    }

    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(context).colorScheme.onSurface,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(ItemDetailDescripton.icon),
            label: ItemDetailDescripton.label,
          ),
          PlatformHelper.isDebug
              ? BottomNavigationBarItem(
                  icon: Icon(ItemRawPropertiesList.icon),
                  label: ItemRawPropertiesList.label,
                )
              : BottomNavigationBarItem(
                  icon: Container(),
                  label: '',
                ),
          BottomNavigationBarItem(
            icon: Icon(ItemDetailAttributesList.icon),
            label: ItemDetailAttributesList.label,
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
      body: Column(
        verticalDirection: VerticalDirection.up,
        children: [
          Expanded(
            child: _widgetOptions[_selectedIndex],
          ),
          ItemDetailsHeader(
            item: widget.item,
          ),
        ],
      ),
    );
  }
}

class ItemDetailsWidget extends StatelessWidget {
  final Item item;

  const ItemDetailsWidget({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final itemRepo = RepositoryProvider.of<ItemRepository>(context);
    final localisation = RepositoryProvider.of<LocalisationRepository>(context);

    final itemIsBlueprint =
        item.parentMarketGroupId == MarketGroupFilters.blueprints.marketGroupId;

    final futures = [
      itemRepo.db.itemBonusTexDao.selectWithIds(
        ids: item.descSpecial ?? [],
      ),
      itemRepo.itemWithId(id: item.product ?? 0),
    ];

    return Container(
      child: FutureBuilder<List<dynamic>>(
          future: Future.wait(futures),
          builder: (context, snapshot) {
            final bonusStrings =
                snapshot.data?[0] as Iterable<ItemBonusText>? ?? [];
            final productItem = snapshot.data?[1] as Item?;

            var desc = [
              item.descKey,
              ...bonusStrings.map((e) => e.localisedTextId),
            ]
                .map(
                  (id) => localisation.getLocalisedStringForIndex(id),
                )
                .join('\n\n');

            if (itemIsBlueprint && productItem != null) {
              final productName = localisation.getLocalisedNameForItem(
                productItem,
              );
              final productDesc = localisation.getLocalisedStringForIndex(
                productItem.descKey,
              );
              desc = sprintf(desc, [
                productName,
                productDesc,
              ]);
            }

            return FutureBuilder<Iterable<ShipAttributeBonus>>(
              initialData: [],
              future: itemRepo.db.itemModifierDao
                  .attributeBonusesForItemId(item.id),
              builder: (context, snapshot) {
                final bonuses = groupBy(
                    snapshot.data!,
                    (ShipAttributeBonus e) =>
                        e.bonusSkillNameId ?? e.bonusSkillId).entries.toList();
                return ListView(
                  children: [
                    ItemDetailDescripton(
                      itemDescription: desc,
                    ),
                    Divider(),
                    StaggeredGridView.extentBuilder(
                      padding: EdgeInsets.all(8),
                      maxCrossAxisExtent: 500,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: bonuses.length,
                      itemBuilder: (BuildContext context, int index) =>
                          ShipBonusWidget(
                        bonusSkillNameId: bonuses[index].key,
                        bonuses: bonuses[index].value,
                      ),
                      staggeredTileBuilder: (int index) => StaggeredTile.fit(1),
                      mainAxisSpacing: 4.0,
                      crossAxisSpacing: 4.0,
                    ),
                  ],
                );
              },
            );
          }),
    );
  }
}
