

import 'package:sweet/database/entities/item.dart';
import 'package:flutter/material.dart';

class ItemRawPropertiesList extends StatelessWidget {
  static const icon = Icons.account_tree_rounded;
  static const label = 'Properties';

  final Item item;

  const ItemRawPropertiesList({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    var itemMap = item.toJson();
    var entriesList = itemMap.entries.where((entry) {
      return entry.key != 'descKey' &&
          entry.key != 'attributeIds' &&
          entry.key != 'effectIds' &&
          entry.key != 'nameKey' &&
          entry.key != 'sourceName' &&
          entry.key != 'sourceDesc';
    }).toList();

    return ListView.builder(
      itemCount: entriesList.length,
      itemBuilder: (context, index) {
        var entry = entriesList[index];
        return Container(
            child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Row(
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(entry.key),
                ),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('${entry.value}'),
                ),
              ),
            ],
          ),
        ));
      },
    );
  }
}
