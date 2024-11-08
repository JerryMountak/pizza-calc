import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:pizza_calc/providers/theme_provider.dart';

// Theme Mode Selector 
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