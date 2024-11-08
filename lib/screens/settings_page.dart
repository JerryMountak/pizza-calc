import 'package:flutter/material.dart';
import 'package:pizza_calc/widgets/compensation_selector.dart';
import 'package:pizza_calc/widgets/preferment_selector.dart';
import 'package:pizza_calc/widgets/tangzhong_selector.dart';
import 'package:provider/provider.dart';

import 'package:pizza_calc/models/pizza_recipe.dart';
import 'package:pizza_calc/providers/advanced_provider.dart';
import 'package:pizza_calc/providers/theme_provider.dart';
import 'package:pizza_calc/widgets/custom_switch_tile.dart';

import 'package:pizza_calc/widgets/theme_selector.dart';

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

              Divider(
                indent: 24,
                endIndent: 24, 
                color: Theme.of(context).colorScheme.outlineVariant,
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

              // Tangzhong
              CustomSwitchTile(
                value: advancedProvider.useTangzhong,
                onTileTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TangzhongSelector()
                    ),
                  );
                },
                onSwitchChanged: (value) {
                  advancedProvider.setUseTangzhong(value);
                },
                title: Text(
                  'Tangzhong',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
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
