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
    return ThemeData.light().copyWith(
      primaryColor: Color(0xFF012966),
      primaryColorLight: Color(0xFF012966),
      primaryColorDark: Color(0xFF012966),
      visualDensity: VisualDensity.adaptivePlatformDensity,
      colorScheme: ColorScheme.light(background: Colors.grey.shade300),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF012966),
      ),
      appBarTheme: AppBarTheme(
        color: Color(0xFF012966),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData.dark().copyWith(
      primaryColor: Color(0xFF0244A7),
      primaryColorLight: Color(0xFF0244A7),
      primaryColorDark: Color(0xFF0244A7),
      visualDensity: VisualDensity.adaptivePlatformDensity,
      colorScheme: ColorScheme.dark(background: Colors.grey.shade600),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF0244A7),
      ),
      appBarTheme: AppBarTheme(
        color: Color(0xFF0244A7),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
    );
  }
}
