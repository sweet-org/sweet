import 'dart:async';
import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:manup/manup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart';
import 'package:http/io_client.dart';

import 'package:sweet/bloc/data_loading_bloc/data_loading.dart';
import 'package:sweet/bloc/item_repository_bloc/item_repository_bloc.dart';
import 'package:sweet/bloc/navigation_bloc/navigation.dart';
import 'package:sweet/repository/character_repository.dart';
import 'package:sweet/repository/implant_fitting_loadout_repository.dart';
import 'package:sweet/repository/localisation_repository.dart';
import 'package:sweet/repository/ship_fitting_repository.dart';
import 'package:sweet/service/attribute_calculator_service.dart';
import 'package:sweet/service/local_notifications_service.dart';
import 'package:sweet/util/constants.dart';
import 'package:sweet/util/platform_helper.dart';

import 'repository/item_repository.dart';
import 'themed_app.dart';


import 'util/crash_reporting.dart';
import 'util/http_client.dart' as http_client;
late File? file;


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final shouldEnableLogging = await PlatformHelper.shouldEnableLogging();
  if (enableFileLogging || shouldEnableLogging) {
    file = await PlatformHelper.logFile();
    print("Logging output goes to ${file!.path}");
    file!.writeAsStringSync(
        "[${DateTime.now()}] Startup\n", mode: FileMode.write);

    overridePrint(() async {
      // Everything inside this is being logged to a file
      await initializeFirebase();
      final shouldEnableSSLFix = await PlatformHelper.shouldEnableSSLFix();
      http_client.enableSSLFix = shouldEnableSSLFix;
      runApp(
        buildRepositories(
          child: buildBlocProviders(
            child: ThemedApp(),
          ),
        ),
      );
    })();
  } else {
    await initializeFirebase();
    final shouldEnableSSLFix = await PlatformHelper.shouldEnableSSLFix();
    http_client.enableSSLFix = shouldEnableSSLFix;
    file = null;
    runApp(
      buildRepositories(
        child: buildBlocProviders(
          child: ThemedApp(),
        ),
      ),
    );
  }
}

void Function() overridePrint(Future<void> Function() mainFn) => () {
  var spec = ZoneSpecification(
      print: (Zone self, ZoneDelegate parent, Zone zone, String line) {
        if (file != null) {
          file!.writeAsStringSync(
              "[${DateTime.now()}] $line\n", mode: FileMode.append);
        }
        parent.print(zone, line);
      }
  );
  return Zone.current.fork(specification: spec).run(mainFn);
};

MultiRepositoryProvider buildRepositories({required Widget child}) {
  final client = http_client.createHttpClient();

  return MultiRepositoryProvider(
    providers: [
      RepositoryProvider<ManUpService>(
        create: (_) => HttpManUpService(
          kManUpUrl,
          http: client,
          os: Platform.operatingSystem,
        ),
      ),
      RepositoryProvider<ItemRepository>(
        create: (_) => ItemRepository(),
      ),
      RepositoryProvider<AttributeCalculatorService>(
        create: (context) => AttributeCalculatorService(
          itemRepository: RepositoryProvider.of<ItemRepository>(context),
        ),
      ),
      RepositoryProvider<LocalisationRepository>(
        create: (context) => LocalisationRepository(
          RepositoryProvider.of<ItemRepository>(context).db,
        ),
      ),
      RepositoryProvider<CharacterRepository>(
        create: (_) => CharacterRepository(),
      ),
      RepositoryProvider<ShipFittingLoadoutRepository>(
        create: (_) => ShipFittingLoadoutRepository(),
      ),
      RepositoryProvider<ImplantFittingLoadoutRepository>(
        create: (_) => ImplantFittingLoadoutRepository(),
      ),
      if (PlatformHelper.hasFirebase)
        RepositoryProvider<FirebaseAnalytics>(
          create: (_) => FirebaseAnalytics.instance,
        ),
      RepositoryProvider<LocalNotificationsService>(
        lazy: false,
        create: (_) => LocalNotificationsService(),
      ),
    ],
    child: child,
  );
}

Widget buildBlocProviders({required Widget child}) {
  return MultiBlocProvider(
    providers: [
      BlocProvider<NavigationBloc>(create: (_) => NavigationBloc()),
      BlocProvider<DataLoadingBloc>(
          create: (context) => DataLoadingBloc(
                RepositoryProvider.of<ItemRepository>(context),
                RepositoryProvider.of<CharacterRepository>(context),
                RepositoryProvider.of<ShipFittingLoadoutRepository>(context),
                RepositoryProvider.of<ImplantFittingLoadoutRepository>(context),
                RepositoryProvider.of<LocalisationRepository>(context),
                RepositoryProvider.of<ManUpService>(context),
              )),
      BlocProvider<ItemRepositoryBloc>(
        create: (context) => ItemRepositoryBloc(
          RepositoryProvider.of<ItemRepository>(context),
        ),
      )
    ],
    child: child,
  );
}
