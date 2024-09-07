import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sweet/database/entities/entities.dart';
import 'package:sweet/util/localisation_constants.dart';

import '../../../repository/localisation_repository.dart';
import '../../../widgets/localised_text.dart';

class NanocoreAffixContextDrawer extends StatefulWidget {
  final List<GoldNanoAttrClass> topClasses;
  final List<ItemNanocoreAffix> initialItems;
  final List<int> blacklistItems;

  NanocoreAffixContextDrawer({
    Key? key,
    List<GoldNanoAttrClass>? topClasses,
    List<ItemNanocoreAffix>? initialFilteredItems,
    List<int>? blacklistItems,
  })  : assert(topClasses != null || initialFilteredItems != null),
        topClasses = topClasses ?? [],
        initialItems = initialFilteredItems ?? [],
        blacklistItems = blacklistItems ?? List<int>.empty(),
        super(key: key);

  @override
  State<NanocoreAffixContextDrawer> createState() =>
      _NanocoreAffixContextDrawerState(initialItems);
}

class _NanocoreAffixContextDrawerState extends State<NanocoreAffixContextDrawer> {
  var _filteredItems = <ItemNanocoreAffix>[];

  _NanocoreAffixContextDrawerState(List<ItemNanocoreAffix> initialItems) {
    _filteredItems = initialItems;
  }

  Future<void> _filterItems(String filterString) async {
    Iterable<ItemNanocoreAffix> items = widget.initialItems;

    setState(() {
      _filteredItems = items.toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    var showMarket = _filteredItems.isEmpty;
    return Container(
      height: 600,
      color: Theme.of(context).canvasColor,
      child: Column(
        children: [
          Expanded(
            child: showMarket ? _buildClassTiles() : _buildFilteredItems(),
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
    sorted.sort((a, b) => a.attrId < b.attrId ? -1 : 1);
    return ListView.builder(
      itemCount: sorted.length,
      itemBuilder: (context, firstLevelindex) {
        var affix = sorted[firstLevelindex];

        return AffixListTile(
          onSelected: (affix) => Navigator.pop(context, affix),
          affix: affix,
        );
      },
    );
  }

  Widget _buildClassTiles() {
    var sorted = widget.topClasses;
    sorted.sort((a, b) => a.classId < b.classId ? -1 : 1);
    return ListView.builder(
      itemCount: sorted.length,
      itemBuilder: (context, firstLevelindex) {
        var child = sorted[firstLevelindex];

        return GoldLibraryGroupTile(
          attrClass: child,
          onAffixSelected: (item) => Navigator.pop(context, item),
          blacklistItems: widget.blacklistItems,
        );
      },
    );
  }
}

typedef AffixCallback = void Function(ItemNanocoreAffix item);

class GoldLibraryGroupTile extends StatelessWidget {
  const GoldLibraryGroupTile(
      {Key? key, required this.attrClass, required this.onAffixSelected, List<int>? blacklistItems })
      : blacklistItems = blacklistItems ?? const [], super(key: key);

  final GoldNanoAttrClass attrClass;
  final AffixCallback onAffixSelected;
  final List<int> blacklistItems;

  @override
  Widget build(BuildContext context) {
    var localisation = RepositoryProvider.of<LocalisationRepository>(context);
    var children = <Widget>[];
    var items = attrClass.items ?? [];

    if (items.isNotEmpty) {
      var sorted = items;
      sorted.sort((a, b) => a.attrId < b.attrId ? -1 : 1);
      children = sorted
          .where((item) => !blacklistItems.any((attrId) => item.attrId == attrId))
          .map((item) => AffixListTile(affix: item, onSelected: onAffixSelected))
          .toList();
    } else {
      var sorted = attrClass.children;
      sorted.sort((a, b) => a.classId < b.classId ? -1 : 1);
      children = sorted
          .map((ac) => GoldLibraryGroupTile(
        attrClass: ac,
        onAffixSelected: onAffixSelected,
        blacklistItems: blacklistItems,
      ))
          .toList();
    }

    var title = localisation.getLocalisedStringForGoldAttrClass(attrClass);
    return ExpansionTile(
      title: Text(title),
      children: children,
    );
  }
}

class AffixListTile extends StatelessWidget {
  const AffixListTile({
    Key? key,
    required this.affix,
    required this.onSelected,
  }) : super(key: key);

  final ItemNanocoreAffix affix;
  final AffixCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onSelected(affix);
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Align(
          alignment: Alignment.centerLeft,
          child: LocalisedText(item: affix.item!),
        ),
      ),
    );
  }
}
