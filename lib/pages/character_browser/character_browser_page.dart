import 'package:sweet/repository/character_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sweet/repository/item_repository.dart';

import 'bloc/character_browser_bloc/bloc.dart';
import 'widget/character_list_view.dart';

class CharacterBrowserPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<CharacterBrowserBloc>(
      create: (context) => CharacterBrowserBloc(
          characterRepository:
              RepositoryProvider.of<CharacterRepository>(context),
          itemRepository: RepositoryProvider.of<ItemRepository>(context)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: CharacterListView(),
      ),
    );
  }
}
