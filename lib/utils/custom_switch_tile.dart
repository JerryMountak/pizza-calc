import 'package:flutter/material.dart';

class CustomSwitchTile extends StatelessWidget {
  final bool value;
  final VoidCallback onTileTap;
  final ValueChanged<bool> onSwitchChanged;
  final Widget title;
  final Widget? subtitle;

  const CustomSwitchTile({
    super.key,
    required this.value,
    required this.onTileTap,
    required this.onSwitchChanged,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Clickable tile area
        Expanded(
          child: InkWell(
            onTap: onTileTap,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  title,
                  if (subtitle != null)
                    subtitle!,
                ],
              ),
            ),
          ),
        ),
        // Vertical separator
        const SizedBox(
          height: 32,
          child: VerticalDivider(
            width: 32,
            thickness: 1,
          ),
        ),
        // Switch area
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: Switch(
            value: value,
            onChanged: onSwitchChanged,
          ),
        ),
      ],
    );
  }
}