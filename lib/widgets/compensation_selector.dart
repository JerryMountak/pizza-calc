import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:pizza_calc/providers/advanced_provider.dart';

class CompensationSelector extends StatefulWidget {
  final Function(int) onCompChanged;
  final int initialValue;

  const CompensationSelector({
    super.key,
    required this.onCompChanged,
    required this.initialValue,
  });

  @override
  State<CompensationSelector> createState() => _CompensationSelectorState();
}

class _CompensationSelectorState extends State<CompensationSelector> {
  late int selectedCompensation;

  @override
  void initState() {
    super.initState();
    selectedCompensation = widget.initialValue;
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
                  'Bowl Compensation',
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
                            'Use bowl compensation',
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
                        value: advancedProvider.bowlCompensation,
                        onChanged: (bool value) {
                          advancedProvider.setBowlCompensation(value);
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
                      RadioListTile<int>(
                        title: Text(
                          '1%',
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
                        value: 1,
                        groupValue: advancedProvider.compPercentage,
                        onChanged: advancedProvider.bowlCompensation
                            ? (int? value) {
                                advancedProvider.setCompPercentage(value!);
                              }
                            : null,
                        activeColor: Theme.of(context).colorScheme.primary,
                      ),
                      RadioListTile<int>(
                        title: Text(
                          '2%',
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
                        value: 2,
                        groupValue: advancedProvider.compPercentage,
                        onChanged: advancedProvider.bowlCompensation
                            ? (int? value) {
                                advancedProvider.setCompPercentage(value!);
                              }
                            : null,
                        activeColor: Theme.of(context).colorScheme.primary,
                      ),
                      RadioListTile<int>(
                        title: Text(
                          '3%',
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
                        value: 3,
                        groupValue: advancedProvider.compPercentage,
                        onChanged: advancedProvider.bowlCompensation
                            ? (int? value) {
                                advancedProvider.setCompPercentage(value!);
                              }
                            : null,
                        activeColor: Theme.of(context).colorScheme.primary,
                      ),
                      RadioListTile<int>(
                        title: Text(
                          '4%',
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
                        value: 4,
                        groupValue: advancedProvider.compPercentage,
                        onChanged: advancedProvider.bowlCompensation
                            ? (int? value) {
                                advancedProvider.setCompPercentage(value!);
                              }
                            : null,
                        activeColor: Theme.of(context).colorScheme.primary,
                      ),
                      RadioListTile<int>(
                        title: Text(
                          '5%',
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
                        value: 5,
                        groupValue: advancedProvider.compPercentage,
                        onChanged: advancedProvider.bowlCompensation
                            ? (int? value) {
                                advancedProvider.setCompPercentage(value!);
                              }
                            : null,
                        activeColor: Theme.of(context).colorScheme.primary,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  """Bowl compensation is a percentage of the total dough weight that is added to compensate for dough residue in the bowl. This can help improve the consistency of your final product.""",
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