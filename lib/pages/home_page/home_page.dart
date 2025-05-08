import 'package:sweet/bloc/item_repository_bloc/item_repository.dart';
import 'package:sweet/bloc/navigation_bloc/navigation.dart';
import 'package:sweet/pages/character_browser/character_browser_page.dart';
import 'package:sweet/pages/fittings_list/fitting_tool_list_page.dart';
import 'package:sweet/pages/implants_list/implant_list_page.dart';
import 'package:sweet/pages/items_browser/items_browser.dart';
import 'package:sweet/pages/market_browser/market_browser.dart';
import 'package:sweet/pages/settings/settings_page.dart';
import 'package:sweet/pages/patch_notes/patch_notes_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'widgets/app_drawer.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationBloc, NavigationState>(
      builder: (BuildContext context, NavigationState state) {
        Widget? body;
        if (state is ResetRootState) {
          switch (state.defaultPage) {
            case RootPages.Settings:
              body = SettingsPage();
              break;
            case RootPages.MarketBrowser:
              body = MarketBrowser();
              BlocProvider.of<ItemRepositoryBloc>(context)
                  .add(FetchMarketGroups());
              break;
            case RootPages.ItemBrowser:
              body = ItemBrowserPage(title: state.title);
              BlocProvider.of<ItemRepositoryBloc>(context)
                  .add(FetchItemCategories());
              break;
            case RootPages.CharacterBrowser:
              body = CharacterBrowserPage();
              break;
            case RootPages.FittingTool:
              body = FittingsListPage();
              break;
            case RootPages.PatchNotes:
              body = PatchNotesPage();
              break;
            case RootPages.ImplantFittings:
              body = ImplantsListPage();
              break;
          }
        }
        if (state is PushNavigationRoute) {
          Navigator.of(context).pushNamed(state.route);
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(state.title),
          ),
          body: body,
          drawer: AppDrawer(),
        );
      },
    );
  }
}
