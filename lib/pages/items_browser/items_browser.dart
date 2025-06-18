import 'package:sweet/bloc/item_repository_bloc/item_repository.dart';
import 'package:sweet/database/entities/item.dart';
import 'package:sweet/pages/item_details/item_details_page.dart';
import 'package:sweet/repository/item_repository.dart';
import 'package:sweet/repository/localisation_repository.dart';
import 'package:sweet/widgets/localised_text.dart';
import 'package:sweet/widgets/search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../database/entities/category.dart';
import '../../database/entities/group.dart';

class ItemBrowserPage extends StatefulWidget {
  ItemBrowserPage({super.key, required this.title});

  final String title;

  @override
  State<ItemBrowserPage> createState() => _ItemBrowserPageState();
}

class _ItemBrowserPageState extends State<ItemBrowserPage> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ItemRepositoryBloc, ItemRepositoryState>(
        builder: (BuildContext context, ItemRepositoryState state) {
      if (state is FilteredItemCategories) {
        var categories = state.filteredCategories.toList();
        categories.sort((a, b) => a.id < b.id ? -1 : 1);
        return Column(
          children: [
            SweetSearchBar(
              onSubmit: (filterString) => context
                  .read<ItemRepositoryBloc>()
                  .add(FilterItems(filterString)),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: categories.length,
                  itemBuilder: (context, categoryIndex) {
                    var category = categories[categoryIndex];
                    return CategoryExpansionTile(
                      category: category,
                    );
                  },
                ),
              ),
            ),
          ],
        );
      } else if (state is FilteredItems) {
        var items = state.filteredItems.toList();
        items.sort((a, b) => a.id < b.id ? -1 : 1);
        return Column(
          children: [
            SweetSearchBar(
              onSubmit: (filterString) => context
                  .read<ItemRepositoryBloc>()
                  .add(FilterItems(filterString)),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    var item = items[index];
                    return ItemListCardWidget(item: item);
                  },
                ),
              ),
            ),
          ],
        );
      }

      return Center(
        child: CircularProgressIndicator(),
      );
    });
  }
}

class CategoryExpansionTile extends StatelessWidget {
  const CategoryExpansionTile({
    super.key,
    required this.category,
  });

  final Category category;

  @override
  Widget build(BuildContext context) {
    var localisation = RepositoryProvider.of<LocalisationRepository>(context);
    var title = localisation.getLocalisedStringForCategory(category);

    return FutureBuilder<Iterable<Group>>(
        future: RepositoryProvider.of<ItemRepository>(context)
            .groupsForCategory(id: category.id),
        builder: (context, snapshot) {
          var groups = snapshot.data?.toList() ?? [];

          return ExpansionTile(
            expandedAlignment: Alignment.centerLeft,
            expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
            leading: Icon(Icons.adjust),
            title: Text(title),
            children: [
              ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: groups.length,
                itemBuilder: (context, index) => GroupExpansionTile(
                  group: groups[index],
                ),
              ),
            ],
          );
        });
  }
}

class GroupExpansionTile extends StatelessWidget {
  const GroupExpansionTile({
    super.key,
    required this.group,
  });

  final Group group;

  @override
  Widget build(BuildContext context) {
    var localisation = RepositoryProvider.of<LocalisationRepository>(context);

    return FutureBuilder<Iterable<Item>>(
        future: RepositoryProvider.of<ItemRepository>(context).itemsForGroup(
          groupId: group.id,
          includeUnpublished: true,
        ),
        builder: (context, snapshot) {
          var items = snapshot.data?.toList() ?? [];
          return ExpansionTile(
            expandedAlignment: Alignment.centerLeft,
            expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
            title: Text(
              localisation.getLocalisedStringForGroup(group),
            ),
            children: [
              ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: items.length,
                itemBuilder: (context, index) => ItemListCardWidget(
                  item: items[index],
                ),
              )
            ],
          );
        });
  }
}

class ItemListCardWidget extends StatelessWidget {
  const ItemListCardWidget({
    super.key,
    required this.item,
  });

  final Item item;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.pushNamed(
        context,
        ItemDetailsPage.routeName,
        arguments: item,
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 16.0),
        child: SizedBox.fromSize(
          size: Size.fromHeight(48),
          child: Align(
            alignment: Alignment.centerLeft,
            child: LocalisedText(
              item: item,
            ),
          ),
        ),
      ),
    );
  }
}
