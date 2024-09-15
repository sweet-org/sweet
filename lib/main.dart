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

import 'package:flutter/foundation.dart' show kDebugMode;

import 'util/crash_reporting.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeFirebase();

  runApp(
    buildRepositories(
      child: buildBlocProviders(
        child: ThemedApp(),
      ),
    ),
  );
}

MultiRepositoryProvider buildRepositories({required Widget child}) {
  final client = _createHttpClient();

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

Client _createHttpClient({bool enableProxy = false}) {
  if (kDebugMode && enableProxy) {
    // Make sure to replace <YOUR_LOCAL_IP> with
    // the external IP of your computer if you're using Android.
    // Note that we're using port 8888 which is Charles' default.
    var proxy = Platform.isAndroid ? '<YOUR_LOCAL_IP>:8888' : 'localhost:8888';

    // Create a new HttpClient instance.
    var httpClient = HttpClient();

    // Hook into the findProxy callback to set
    // the client's proxy.
    httpClient.findProxy = (uri) {
      return 'PROXY $proxy;';
    };

    // This is a workaround to allow Charles to receive
    // SSL payloads when your app is running on Android
    httpClient.badCertificateCallback =
        ((X509Certificate cert, String host, int port) => Platform.isAndroid);

    return IOClient(httpClient);
  }

  return Client();
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
