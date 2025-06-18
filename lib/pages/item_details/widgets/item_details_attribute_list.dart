import 'package:sweet/database/entities/attribute.dart';
import 'package:sweet/database/entities/item_attribute_value.dart';
import 'package:sweet/widgets/item_attribute_value_widget.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sweet/database/entities/item.dart';
import 'package:sweet/repository/item_repository.dart';
import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';

class ItemDetailAttributesList extends StatelessWidget {
  static const icon = Icons.book;
  static const label = 'Raw Attributes';

  final Item item;

  const ItemDetailAttributesList({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    var itemRepo = RepositoryProvider.of<ItemRepository>(context);
    // TODO: This could be combined into a single Query
    return FutureBuilder<Iterable<ItemAttributeValue>>(
      future: itemRepo.attributeIdsForItem(item: item),
      builder: (context, valuesSnapshot) {
        if (!valuesSnapshot.hasData) {
          return CircularProgressIndicator();
        }
        var values = valuesSnapshot.data!.toList();

        var ids = values
            .map(
              (e) => e.attributeId,
            )
            .toList();
        ids.sort((a, b) => a.compareTo(b));
        return FutureBuilder<Iterable<Attribute>>(
            future: itemRepo.attributesWithIds(ids: ids),
            builder: (context, attrSnapshot) {
              if (!attrSnapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }
              var attributesValues = values;
              var attrMap = {for (var a in attrSnapshot.data!) a.id: a};

              return GroupedListView<ItemAttributeValue, int>(
                elements: attributesValues,
                groupBy: (e) => attrMap[e.attributeId]?.attributeCategory ?? 0,
                groupSeparatorBuilder: (i) => Container(
                  color: Colors.grey,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Center(
                      child: Text(
                        ' ',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ),
                itemBuilder: (context, ItemAttributeValue e) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: e.value != 0
                        ? ItemAttributeValueWidget(
                            attributeId: e.attributeId,
                            attributeValue: e.value,
                            fixedDecimals: 4,
                          )
                        : Container(),
                  );
                },
              );
            });
      },
    );
  }
}
