import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:pizza_calc/models/pizza_recipe.dart';
import 'package:pizza_calc/providers/advanced_provider.dart';

class PrefermentSelector extends StatefulWidget {
  final Function(PrefermentType) onPrefermentChanged;
  final PrefermentType initialValue;

  const PrefermentSelector({
    super.key,
    required this.onPrefermentChanged,
    required this.initialValue,
  });

  @override
  State<PrefermentSelector> createState() => _PrefermentSelectorState();
}

class _PrefermentSelectorState extends State<PrefermentSelector> {
  late PrefermentType selectedPreferment;

  @override
  void initState() {
    super.initState();
    selectedPreferment = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdvancedProvider>(
      builder: (context, advancedProvider, child) {
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Preferments',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const SizedBox(width: 12),
                          Text(
                            'Use preferments',
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      Switch(
                        value: advancedProvider.usePreferments,
                        onChanged: (bool value) {
                          advancedProvider.setUsePreferments(value);
                        },
                      ),
                    ],
                  ),
                ),
                Divider(color: Theme.of(context).colorScheme.outlineVariant),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      RadioListTile<PrefermentType>(
                        title: Text(
                          'Poolish',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    // If switch is off, reduce opacity to 0.5
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.color
                                        ?.withOpacity(
                                          advancedProvider.usePreferments
                                              ? 1.0
                                              : 0.5,
                                        ),
                                  ),
                        ),
                        value: PrefermentType.poolish,
                        groupValue: advancedProvider.prefermentType,
                        onChanged: advancedProvider.usePreferments
                            ? (PrefermentType? value) {
                                advancedProvider.setPrefermentType(value!);
                              }
                            : null,
                        activeColor: Theme.of(context).colorScheme.primary,
                      ),
                      RadioListTile<PrefermentType>(
                        title: Text(
                          'Biga',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    // If switch is off, reduce opacity to 0.5
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.color
                                        ?.withOpacity(
                                          advancedProvider.usePreferments
                                              ? 1.0
                                              : 0.5,
                                        ),
                                  ),
                        ),
                        value: PrefermentType.biga,
                        groupValue: advancedProvider.prefermentType,
                        onChanged: advancedProvider.usePreferments
                            ? (PrefermentType? value) {
                                advancedProvider.setPrefermentType(value!);
                              }
                            : null,
                        activeColor: Theme.of(context).colorScheme.primary,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  // Display description for selected item
                  advancedProvider.usePreferments
                      ? advancedProvider.prefermentType.description
                      : 'Choose your preferred preferment type. You can change this setting at any time.',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.justify,
                )
              ],
            ),
          ),
        );
      },
    );
  }
}