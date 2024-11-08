import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeState {
  final ColorScheme? lightDynamic;
  final ColorScheme? darkDynamic;
  final ThemeMode themeMode;
  final bool useDynamicColors;

  ThemeState({
    this.lightDynamic,
    this.darkDynamic,
    required this.themeMode,
    required this.useDynamicColors,
  });
}

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  bool _useDynamicColors = false;
  ColorScheme? _lightDynamic;
  ColorScheme? _darkDynamic;
  bool _isInitialized = false;

  ThemeMode get themeMode => _themeMode;
  bool get useDynamicColors => _useDynamicColors;
  bool get isInitialized => _isInitialized;
  ColorScheme? get lightDynamic => _lightDynamic;
  ColorScheme? get darkDynamic => _darkDynamic;

  // Initialize everything before the first build
  static Future<ThemeState> initializeTheme() async {
    // Load preferences
    final prefs = await SharedPreferences.getInstance();
    final themeMode = ThemeMode.values.firstWhere(
      (mode) => mode.name == prefs.getString('themeMode'),
      orElse: () => ThemeMode.light,
    );
    final useDynamicColors = prefs.getBool('useDynamicColors') ?? false;

    // Pre-load dynamic colors
    ColorScheme? lightDynamic;
    ColorScheme? darkDynamic;
    
    try {
      final corePalette = await DynamicColorPlugin.getCorePalette();
      if (corePalette != null) {
        dev.log('Core palette retrieved: ${corePalette.primary.get(40)}');

        // lightDynamic = corePalette.toColorScheme(brightness: Brightness.light);
        lightDynamic = ColorScheme.fromSeed(
          seedColor: Color(corePalette.primary.get(40)),
          brightness: Brightness.light,
        );

        // darkDynamic = corePalette.toColorScheme(brightness: Brightness.dark);
        darkDynamic = ColorScheme.fromSeed(
          seedColor: Color(corePalette.primary.get(40)),
          brightness: Brightness.dark,
        );
      }
      else {
        dev.log("Device doesn't provide a core palette");
      }
    } catch (e, stackTrace) {
    dev.log('Error loading dynamic colors: $e');
    dev.log('Stack trace: $stackTrace');
  }

    return ThemeState(
      lightDynamic: lightDynamic,
      darkDynamic: darkDynamic,
      themeMode: themeMode,
      useDynamicColors: useDynamicColors,
    );
  }

  // Initialize from the pre-loaded state
  void initializeFromState(ThemeState state) {
    _themeMode = state.themeMode;
    _useDynamicColors = state.useDynamicColors;
    _lightDynamic = state.lightDynamic;
    _darkDynamic = state.darkDynamic;
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', mode.name);
    notifyListeners();
  }

  Future<void> toggleDynamicColors() async {
    _useDynamicColors = !_useDynamicColors;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('useDynamicColors', _useDynamicColors);
    notifyListeners();
  }
}