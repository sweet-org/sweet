import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sweet/database/database_exports.dart';

import 'package:sweet/repository/item_repository.dart';
import 'package:flutter/material.dart';

class ItemDetailEffectsList extends StatelessWidget {
  static const icon = Icons.healing;
  static const label = 'Effects';

  final Item item;

  const ItemDetailEffectsList({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var itemRepo = RepositoryProvider.of<ItemRepository>(context);
    return FutureBuilder<Iterable<ItemEffect>>(
        future: itemRepo.itemEffects(forItem: item),
        initialData: [],
        builder: (context, snapshot) {
          var effects = snapshot.data?.toList() ?? [];

          return ListView.builder(
            itemCount: effects.length,
            itemBuilder: (context, index) {
              var itemEffect = effects[index];
              return FutureBuilder<Effect?>(
                  future: itemRepo.effectWithId(id: itemEffect.effectId),
                  builder: (context, snapshot) {
                    return SizedBox(
                      height: 48,
                      child: Card(
                        color: itemEffect.isDefault
                            ? Colors.white
                            : Colors.grey.shade300,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child:
                                Text(snapshot.data?.effectName ?? '- None -'),
                          ),
                        ),
                      ),
                    );
                  });
            },
          );
        });
  }
}
