import 'dart:developer' as dev;
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
    } catch (e) {
      // Handle any errors loading dynamic colors
      dev.log('Error loading dynamic colors: $e');
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

class ToggleButtonsOption<T> {
  final ThemeMode value;
  final Widget widget;

  const ToggleButtonsOption(this.value, this.widget);
}

class ThemeSelector extends StatefulWidget {
  final Function(ThemeMode) onThemeChanged;
  final ThemeMode initialValue;

  const ThemeSelector({
    super.key,
    required this.onThemeChanged,
    required this.initialValue,
  });

  @override
  State<ThemeSelector> createState() => _ThemeSelectorState();
}

class _ThemeSelectorState extends State<ThemeSelector> {
  late ThemeMode selectedTheme;

  @override
  void initState() {
    super.initState();
    selectedTheme = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    List<ToggleButtonsOption> options = [
      const ToggleButtonsOption(
        ThemeMode.light,
        Icon(Icons.light_mode, semanticLabel: "Light")
      ),
      const ToggleButtonsOption(
        ThemeMode.dark,
        Icon(Icons.dark_mode, semanticLabel: "Dark")
      ),
      const ToggleButtonsOption(
        ThemeMode.system,
        Icon(Icons.brightness_auto, semanticLabel: "System")
      ),
    ];

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(5.0, 5.0, 0.0, 5.0),
          child: ListTile(
            title: Text('Theme', style: Theme.of(context).textTheme.titleMedium,),
            trailing: ToggleButtons(
              borderRadius: BorderRadius.circular(1000),
              onPressed: (int index) {
                themeProvider.setThemeMode(options[index].value);
              },
              isSelected: options
                  .map((option) => themeProvider.themeMode == option.value)
                  .toList(),
              children: options.map((option) => option.widget).toList(),
            ),
          ),
        );
      },
    );
  } 
}