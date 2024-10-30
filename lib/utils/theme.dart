import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ThemeProvider with ChangeNotifier {
  late ThemeMode _themeMode = ThemeMode.light;
  bool _useDynamicColors = false;

  ThemeMode get themeMode => _themeMode;
  bool get useDynamicColors => _useDynamicColors;

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  void toggleDynamicColors() {
    _useDynamicColors = !_useDynamicColors;
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
      ToggleButtonsOption(
        ThemeMode.light,
        const Icon(Icons.light_mode, semanticLabel: "Light")
      ),
      ToggleButtonsOption(
        ThemeMode.dark,
        const Icon(Icons.dark_mode, semanticLabel: "Dark")
      ),
      ToggleButtonsOption(
        ThemeMode.system,
        const Icon(Icons.brightness_auto, semanticLabel: "System")
      ),
    ];

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(5.0, 5.0, 0.0, 5.0),
          child: ListTile(
            title: const Text('Theme'),
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