import 'package:flutter/material.dart';
import 'package:pizza_calc/models/pizza_recipe.dart';


class YeastSelector extends StatefulWidget {
  final Function(YeastType) onYeastTypeChanged;
  final YeastType initialValue;

  const YeastSelector({
    super.key,
    required this.onYeastTypeChanged,
    this.initialValue = YeastType.active,
  });

  @override
  State<YeastSelector> createState() => _YeastSelectorState();
}

class _YeastSelectorState extends State<YeastSelector> {
  late YeastType selectedYeastType;

  @override
  void initState() {
    super.initState();
    selectedYeastType = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Yeast Type',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 10),
          SegmentedButton<YeastType>(
            segments: const [
              ButtonSegment<YeastType>(
                value: YeastType.active,
                label: Text('Active Dry'),
              ),
              ButtonSegment<YeastType>(
                value: YeastType.instant,
                label: Text('Instant'),
              ),
            ],
            selected: {selectedYeastType},
            onSelectionChanged: (Set<YeastType> newSelection) {
              setState(() {
                selectedYeastType = newSelection.first;
              });
              widget.onYeastTypeChanged(newSelection.first);
            },
          ),
        ],
      ),
    );
  }
}