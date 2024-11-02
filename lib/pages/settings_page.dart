import 'package:flutter/material.dart';
import 'package:pizza_calc/utils/custom_switch_tile.dart';
import 'package:pizza_calc/utils/advanced_features.dart';
import 'package:pizza_calc/utils/theme.dart';
import 'package:provider/provider.dart';

class SettingsTab extends StatefulWidget {
  const SettingsTab({super.key});

  @override
  SettingsTabState createState() => SettingsTabState();
}

class SettingsTabState extends State<SettingsTab> {
  bool isSwitchEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, AdvancedProvider>(
        builder: (context, themeProvider, advancedProvider, child) {
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
                  style: Theme.of(context).textTheme.labelSmall?.apply(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ),

              // App Theme
              ThemeSelector(
                onThemeChanged: themeProvider.setThemeMode,
                initialValue: ThemeMode.light
              ),

              // Material You Colors
              SwitchListTile(
                title: Text(
                  'Material You',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                subtitle: Text(
                  'Dynamic colors based on your device',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                value: themeProvider.useDynamicColors,
                onChanged: (bool value) {
                  themeProvider.toggleDynamicColors();
                },
                contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
              ),

              const Divider(
                indent: 24,
                endIndent: 24,
              ),

              // Advanced Features
              Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 0.0),
                child: Text(
                  'Advanced Features',
                  style: Theme.of(context).textTheme.labelSmall?.apply(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ),

              // Preferments
              CustomSwitchTile(
                value: advancedProvider.usePreferments,
                onTileTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PrefermentSelector(
                        onPrefermentChanged:
                            advancedProvider.setPrefermentType,
                        initialValue: PrefermentType.poolish,
                      ),
                    ),
                  );
                },
                onSwitchChanged: (value) {
                  advancedProvider.setUsePreferments(value);
                },
                title: Text(
                  'Preferments',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                subtitle: Text(
                  advancedProvider.usePreferments
                      ? advancedProvider.prefermentType.displayName
                      : 'Choose preferment type',
                  style: Theme.of(context).textTheme.bodySmall,
                )
              ),

              // Bowl Compensation
              CustomSwitchTile(
                value: advancedProvider.bowlCompensation,
                onTileTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CompensationSelector(
                        onCompChanged: advancedProvider.setCompPercentage,
                        initialValue: advancedProvider.compPercentage,
                      ),
                    ),
                  );
                  // print("Bowl compensation tapped");
                },
                onSwitchChanged: (value) {
                  advancedProvider.setBowlCompensation(value);
                },
                title: Text(
                  'Bowl Compensation',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                subtitle: Text(
                  advancedProvider.bowlCompensation
                      ? "${advancedProvider.compPercentage.toString()}%"
                      : 'Compensate for dough residue',
                  style: Theme.of(context).textTheme.bodySmall,
                )
              ),
            ]
          )
        ),
      );
    });
  }
}
