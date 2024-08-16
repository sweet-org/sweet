import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as utils;

import 'package:sweet/bloc/data_loading_bloc/data_loading.dart';
import 'package:sweet/mixins/file_selector_mixin.dart';
import 'package:sweet/pages/character_profile/widgets/character_profile_header.dart';
import 'package:sweet/pages/home_page/widgets/app_update_banner.dart';
import 'package:sweet/pages/home_page/widgets/pi_reminder.dart';
import 'package:sweet/util/localisation_constants.dart';
import 'package:sweet/util/platform_helper.dart';

import '../../ship_fitting/widgets/pilot_context_drawer.dart';
import '../../../bloc/navigation_bloc/navigation.dart';
import '../../../model/character/character.dart';
import '../../../repository/character_repository.dart';

import 'app_banner.dart';
import 'social_button.dart';
import 'version_label.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({
    Key? key,
  }) : super(key: key);

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> with FileSelector {
  @override
  Widget build(BuildContext context) {
    final theme = AdaptiveTheme.of(context);

    final currentMode = theme.mode == AdaptiveThemeMode.system
        ? 'System'
        : theme.mode == AdaptiveThemeMode.dark
            ? 'Dark'
            : 'Light';

    final charRepo = RepositoryProvider.of<CharacterRepository>(context);

    return SafeArea(
      child: Drawer(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Column(
              children: [
                Center(
                  child: AppBanner(),
                ),
                Container(
                  height: 1,
                  color: Theme.of(context).secondaryHeaderColor,
                ),
                Expanded(
                  child: ListView(
                    // Important: Remove any padding from the ListView.
                    padding: EdgeInsets.zero,
                    children: <Widget>[
                      AppUpdateBanner(),
                      ListTile(
                        leading: Icon(
                          Icons.airline_seat_recline_extra_outlined,
                          size: 24,
                          color: Theme.of(context).primaryColor,
                        ),
                        title: Text(StaticLocalisationStrings.defaultPilot),
                        subtitle: Text(charRepo.defaultPilot.name),
                        onTap: () => showPilotDrawer(context),
                      ),
                      PIReminder(),
                      buildDrawerListTile(
                        context,
                        title: 'Character Browser',
                        icon: Icons.person,
                        event: ShowCharacterBrowserPage(),
                      ),
                      buildDrawerListTile(
                        context,
                        title: 'Market Browser',
                        icon: Icons.shopping_cart,
                        event: ShowMarketBrowserPage(),
                      ),
                      PlatformHelper.isDebug
                          ? buildDrawerListTile(context,
                              title: 'Items Browser',
                              icon: Icons.book,
                              event: ShowItemBrowserPage())
                          : Container(),
                      buildDrawerListTile(
                        context,
                        title: 'Fitting Tool',
                        icon: Icons.construction,
                        event: ShowFittingToolPage(),
                      ),
                      buildDrawerListTile(
                        context,
                        title: 'Implant List',
                        icon: Icons.construction,
                        event: ShowImplantToolPage(),
                      ),
                      buildDrawerListTile(
                        context,
                        title: 'Announcements',
                        icon: Icons.announcement,
                        event: ShowPatchNotesPage(),
                      ),
                      ListTile(
                        leading: Icon(
                          Icons.nightlight_round,
                          size: 24,
                          color: Theme.of(context).primaryColor,
                        ),
                        title: Text(StaticLocalisationStrings.theme),
                        subtitle: Text(currentMode),
                        onTap: () {
                          theme.toggleThemeMode();
                        },
                      ),
                      ListTile(
                        leading: Icon(
                          Icons.import_export,
                          size: 24,
                          color: Theme.of(context).primaryColor,
                        ),
                        title: Text(StaticLocalisationStrings.importExport),
                        onTap: _importExportDialog,
                      ),
                    ],
                  ),
                ),
                VersionLabel(
                  color: Theme.of(context)
                      .textTheme
                      .bodyLarge!
                      .color!
                      .withAlpha(128),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: SocialButton(
                    assetName: 'assets/branding/discord-logo-white.svg',
                    socialUrl: 'https://discord.gg/2QyVpSJKte',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ListTile buildDrawerListTile(BuildContext context,
      {required String title,
      required IconData icon,
      required NavigationEvent event}) {
    return ListTile(
      leading: Icon(
        icon,
        size: 24,
        color: Theme.of(context).primaryColor,
      ),
      title: Text(title),
      onTap: () {
        BlocProvider.of<NavigationBloc>(context).add(event);
        Navigator.of(context).pop();
      },
    );
  }

  Future<void> showPilotDrawer(BuildContext context) async {
    var selection = await showModalBottomSheet<Character>(
      context: context,
      elevation: 16,
      builder: (context) => PilotContextDrawer(),
    );

    if (selection != null) {
      final charRepo = RepositoryProvider.of<CharacterRepository>(context);
      await charRepo.setDefaultPilot(pilot: selection);
      setState(() {});
    }
  }

  Future<void> _importExportDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext dialogContext) {
        return ImportExportDialog(
          title: 'Import/Export Data',
          description:
              'Importing will override all skills and fittings and cannot be undone!',
          onExport: () => _exportFromFile(),
          onImport: () => _importFromFile(),
        );
      },
    );
  }

  Future<void> _exportFromFile() async {
    final folder = await selectFolder();

    if (folder != null) {
      final path = utils.join(
        folder,
        DateFormat('yyyyMMdd-HHmm').format(DateTime.now()),
      );
      context.read<DataLoadingBloc>().add(ExportDataEvent(path: path));
    }
  }

  Future<void> _importFromFile() async {
    final path = await selectFile();

    if (path != null) {
      context.read<DataLoadingBloc>().add(ImportDataEvent(path: path));
    }
  }
}
