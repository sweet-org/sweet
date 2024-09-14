import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sweet/model/character/character.dart';
import 'package:sweet/database/entities/item.dart';
import 'package:sweet/pages/implant_fitting/implant_fitting_page.dart';
import 'package:sweet/repository/character_repository.dart';
import 'package:sweet/service/fitting_simulator.dart';
import 'package:sweet/pages/character_profile/character_profile_page.dart';
import 'package:sweet/pages/item_details/item_details_page.dart';
import 'package:sweet/pages/ship_fitting/ship_fitting_page.dart';
import 'package:flutter/material.dart';
import 'package:sweet/util/platform_helper.dart';

import 'model/implant/implant_handler.dart';
import 'pages/root_page/root_page.dart';

class App extends StatelessWidget {
  final ThemeData lightTheme;
  final ThemeData darkTheme;

  const App({
    Key? key,
    required this.lightTheme,
    required this.darkTheme,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'SWEET',
        debugShowCheckedModeBanner: false,
        theme: lightTheme,
        darkTheme: darkTheme,
        initialRoute: '/',
        navigatorObservers: [
          if (PlatformHelper.hasFirebase)
            FirebaseAnalyticsObserver(
              analytics: RepositoryProvider.of<FirebaseAnalytics>(context),
            ),
        ],
        onGenerateRoute: (settings) {
          if (settings.name == '/') {
            return PageRouteBuilder(
              pageBuilder: (_, __, ___) => RootPage(),
              transitionsBuilder: (_, anim, __, child) {
                return buildSlideTransitionForChild(anim, child);
              },
            );
          }

          if (settings.name == CharacterProfilePage.routeName) {
            var character = settings.arguments as Character;
            return PageRouteBuilder(
              pageBuilder: (_, __, ___) => CharacterProfilePage(
                character: character,
              ),
              transitionsBuilder: (_, anim, __, child) {
                return buildSlideTransitionForChild(anim, child);
              },
            );
          }

          if (settings.name == ItemDetailsPage.routeName) {
            final item = settings.arguments as Item;
            return PageRouteBuilder(
              pageBuilder: (_, __, ___) => ItemDetailsPage(
                item: item,
              ),
              transitionsBuilder: (_, anim, __, child) {
                return buildSlideTransitionForChild(anim, child);
              },
            );
          }

          if (settings.name == ShipFittingPage.routeName) {
            final fitting = settings.arguments as FittingSimulator;
            final charRepo =
                RepositoryProvider.of<CharacterRepository>(context);
            fitting.setPilot(charRepo.defaultPilot);
            return PageRouteBuilder(
              pageBuilder: (_, __, ___) => ShipFittingPage(
                fitting: fitting,
              ),
              transitionsBuilder: (_, anim, __, child) {
                return buildSlideTransitionForChild(anim, child);
              },
            );
          }

          if (settings.name == ImplantFittingPage.routeName) {
            final fitting = settings.arguments as ImplantHandler;
            //final charRepo =
            //RepositoryProvider.of<CharacterRepository>(context);
            // fitting.setPilot(charRepo.defaultPilot);
            return PageRouteBuilder(
              pageBuilder: (_, __, ___) => ImplantFittingPage(
                implant: fitting,
              ),
              transitionsBuilder: (_, anim, __, child) {
                return buildSlideTransitionForChild(anim, child);
              },
            );
          }

          return null;
        },
      );
}

SlideTransition buildSlideTransitionForChild(
    Animation<double> anim, Widget child) {
  var start = Offset(1.0, 0.0);
  var end = Offset.zero;
  var curve = Curves.ease;
  var tween = Tween(begin: start, end: end).chain(CurveTween(curve: curve));
  return SlideTransition(position: anim.drive(tween), child: child);
}
