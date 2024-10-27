import 'package:flutter/material.dart';
import 'package:pizza_calc/utils/theme.dart';
import 'package:provider/provider.dart';

class SettingsTab extends StatefulWidget {
  const SettingsTab({super.key});

  @override
  SettingsTabState createState() => SettingsTabState();
}

class SettingsTabState extends State<SettingsTab> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text("Settings"),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Appearance Settings
              Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 20.0, 10.0, 0.0),
                child: Text(
                  'Appearance',
                  style: TextStyle(
                    fontSize: 10,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              
              // App Theme
              ThemeSelector(onThemeChanged: themeProvider.setThemeMode, initialValue: ThemeMode.light),

              // Material You Colors
              SwitchListTile(
                title: const Text('Material You'),
                subtitle: const Text('Dynamic colors based on your device', style: TextStyle(fontSize: 11),),
                value: themeProvider.useDynamicColors,
                onChanged: (bool value) {
                  themeProvider.toggleDynamicColors();
                },
                activeColor: Theme.of(context).colorScheme.secondary,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
              ),
            ],
          ),
        ),
      );
    }
    );
  }
}
