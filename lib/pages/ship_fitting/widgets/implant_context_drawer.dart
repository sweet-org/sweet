import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:sweet/repository/implant_fitting_loadout_repository.dart';
import 'package:sweet/repository/item_repository.dart';
import 'package:sweet/widgets/localised_text.dart';

import '../../../database/entities/item.dart';

class ImplantContextDrawer extends StatelessWidget {
  const ImplantContextDrawer({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final itemRepo = RepositoryProvider.of<ItemRepository>(context);
    final implantRepo =
        RepositoryProvider.of<ImplantFittingLoadoutRepository>(context);

    final implants = [...implantRepo.implants];
    final itemFuture = itemRepo
        .itemsWithIds(ids: List.of(implants.map((e) => e.implantItemId)))
        .then((value) => Map.fromEntries(value.map((e) => MapEntry(e.id, e))));

    return Container(
      height: 600,
      color: Theme.of(context).canvasColor,
      child: FutureBuilder<Map<int, Item>>(
          future: itemFuture,
          builder:
              (BuildContext context, AsyncSnapshot<Map<int, Item>> snapshot) {
            return ListView.builder(
              itemCount: implants.length,
              itemBuilder: (context, index) {
                var implant = implants[index];
                Widget? itemName;
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                  case ConnectionState.waiting:
                    itemName = null;
                    break;
                  default:
                    if (snapshot.hasError) {
                      throw snapshot.error!;
                    }
                    final data = snapshot.data!;
                    if (!data.containsKey(implant.implantItemId)) {
                      itemName = Container();
                    } else {
                      itemName =
                          LocalisedText(item: data[implant.implantItemId]!);
                    }
                }

                return InkWell(
                    onTap: () => Navigator.pop(context, implant),
                    child: Card(
                      clipBehavior: Clip.antiAlias,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minHeight: 72),
                        child: Padding(
                            padding: const EdgeInsets.only(
                              top: 8.0,
                              bottom: 8.0,
                              left: 8.0,
                              right: 32.0,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.account_tree_rounded,
                                  size: 56.0,
                                ),
                                Expanded(
                                    flex: 2,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        AutoSizeText(
                                          implant.name,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 40),
                                        ),
                                        itemName ??
                                            Text(
                                              'Item ID ${implant.implantItemId}',
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .bodyLarge!
                                                    .color!
                                                    .withAlpha(96),
                                              ),
                                            ),
                                      ],
                                    ))
                              ],
                            )),
                      ),
                    ));
              },
            );
          }),
    );
  }
}
