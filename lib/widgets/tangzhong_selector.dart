import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:pizza_calc/providers/advanced_provider.dart';

class TangzhongSelector extends StatefulWidget {
  const TangzhongSelector({super.key,});

  @override
  State<TangzhongSelector> createState() => _TangzhongSelectorState();
}

class _TangzhongSelectorState extends State<TangzhongSelector> {
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
                  'Tangzhong',
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
                            'Use tangzhong',
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
                        value: advancedProvider.useTangzhong,
                        onChanged: (bool value) {
                          advancedProvider.setUseTangzhong(value);
                        },
                      ),
                    ],
                  ),
                ),
                Divider(color: Theme.of(context).colorScheme.outlineVariant),
                Text(
                  // Display description for selected item
                  """Tangzhong is an Asian technique that calls for pre-cooking a portion of the raw flour in a recipe with a liquid (usually water or milk) until it forms a paste. Then, this paste can be added to dough, resulting in bread that's tenderer, more fluffy, and lasts longer before staling.
                  
                  This technique shows better results when the dough is made with a higher hydration ratio (above 75%).""",
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