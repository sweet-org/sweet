import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tinycolor2/tinycolor2.dart';

import 'app.dart';

class ThemedApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => AdaptiveTheme(
        light: _buildLightTheme(),
        dark: _buildDarkTheme(),
        initial: AdaptiveThemeMode.dark,
        builder: (theme, darkTheme) => App(
          lightTheme: theme,
          darkTheme: darkTheme,
        ),
      );

  ThemeData _buildLightTheme() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: Color(0xFF0244A7),
      brightness: Brightness.light,
      primary: Color(0xFF0244A7),
      onPrimary: Colors.white,
      primaryFixed: Color(0xFF0244A7),
      primaryContainer: Color(0xFF0244A7),
      onPrimaryContainer: Colors.white,
    );
    return ThemeData(
      useMaterial3: true,
      primaryColor: Color(0xFF012966),
      primaryColorLight: Color(0xFF012966),
      primaryColorDark: Color(0xFF012966),
      visualDensity: VisualDensity.adaptivePlatformDensity,
      colorScheme: colorScheme, //MaterialTheme.lightScheme(),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF012966),
      ),
      appBarTheme: AppBarTheme(
        foregroundColor: colorScheme.onPrimary,
        backgroundColor: colorScheme.primary,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    // This is a automatically generated color scheme for reference.
    // The goal is that the UI looks good on Material 3 themes, even though
    // we currently use custom colors.

    //final colorScheme = ColorScheme.fromSeed(
    //  seedColor: Color(0xFF0244A7),
    //  brightness: Brightness.dark,
    //  dynamicSchemeVariant: DynamicSchemeVariant.vibrant,
    //);
    final colorScheme = ColorScheme.dark(
      primary: Color(0xFF0244A7),
      onPrimary: Colors.white,
      primaryFixed: Color(0xFF0244A7),
      primaryContainer: Color(0xFF0244A7),
      onPrimaryContainer: Colors.white,
      secondary: Color(0xFF0244A7),
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFF535353),
      onSecondaryContainer: Colors.white,
      surface: Color(0xFF12121A),
      onSurface: Colors.white,
      surfaceContainer: Color(0xFF161820),
      surfaceContainerHigh: Color(0xFF161820).brighten(2),
      surfaceContainerLow: Color(0xFF161820).darken(1),
    );
    return ThemeData(
      useMaterial3: true,
      primaryColor: Color(0xFF0244A7),
      primaryColorLight: Color(0xFF0244A7),
      primaryColorDark: Color(0xFF0244A7),
      visualDensity: VisualDensity.adaptivePlatformDensity,
      colorScheme: colorScheme,
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF0244A7),
      ),
      appBarTheme: AppBarTheme(
        foregroundColor: colorScheme.onPrimaryContainer,
        backgroundColor: colorScheme.primaryContainer,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
    );
  }
}
