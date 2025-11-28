import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
    );
    return ThemeData(
      useMaterial3: true,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      colorScheme: colorScheme,
      //floatingActionButtonTheme: FloatingActionButtonThemeData(
      //  backgroundColor: Color(0xFF012966),
      //),
      appBarTheme: AppBarTheme(
        foregroundColor: colorScheme.onPrimary,
        backgroundColor: colorScheme.primary,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: Color(0xFF0244A7),
      brightness: Brightness.dark,
    );
    return ThemeData(
      useMaterial3: true,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      colorScheme: colorScheme,
      appBarTheme: AppBarTheme(
        foregroundColor: colorScheme.onPrimaryContainer,
        backgroundColor: colorScheme.primaryContainer,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
    );
  }
}
