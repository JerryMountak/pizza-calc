import 'package:flutter/material.dart';

class IngredientData {
  final String label;
  final double value;

  const IngredientData({
    required this.label,
    required this.value,
  });
}

class RecipeIngredients extends StatefulWidget {
  final List<IngredientData> initialIngredients;

  const RecipeIngredients({
    super.key,
    required this.initialIngredients,
  });

  @override
  RecipeIngredientsState createState() => RecipeIngredientsState();
}

class RecipeIngredientsState extends State<RecipeIngredients> {
  late List<IngredientData> ingredients;

  @override
  void initState() {
    super.initState();
    ingredients = List.from(widget.initialIngredients); // Create a copy of the list
  }

  @override
  void didUpdateWidget(RecipeIngredients oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Check if the new ingredients list is different from the current one
    if (widget.initialIngredients != oldWidget.initialIngredients) {
      setState(() {
        ingredients = List.from(widget.initialIngredients);
      });
    }
  }

  // Function to update ingredients
  void updateIngredients(List<IngredientData> newIngredients) {
    setState(() {
      ingredients = List.from(newIngredients);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    // Determine number of columns based on screen width
    int crossAxisCount;
    if (screenWidth < 400) {
      crossAxisCount = 2;
    } else if (screenWidth < 800) {
      crossAxisCount = 3;
    } else {
      crossAxisCount = 4;
    }

    // Adjust for orientation
    if (!isPortrait) {
      crossAxisCount += 1;
    }

    // Smaller padding (3% of screen width instead of 4%)
    final padding = screenWidth * 0.03;

    // Reduced aspect ratio for smaller pills
    final aspectRatio = isPortrait ? 1.8 : 2.0;

    return Padding(
      padding: EdgeInsets.all(padding),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: padding,
          mainAxisSpacing: padding,
          childAspectRatio: aspectRatio,
        ),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: ingredients.length,
        itemBuilder: (context, index) {
          final ingredient = ingredients[index];
          return _buildIngredientPill(
            context,
            ingredient.label,
            ingredient.value.toStringAsFixed(
                ingredient.value.truncateToDouble() == ingredient.value
                    ? 0
                    : 2),
            screenWidth,
          );
        },
      ),
    );
  }

  Widget _buildIngredientPill(
      BuildContext context, String label, String value, double screenWidth) {
    final colorScheme = Theme.of(context).colorScheme;

    // Reduced font sizes
    final labelSize = screenWidth * 0.025;
    final valueSize = screenWidth * 0.035;
    final unitSize = screenWidth * 0.025;

    // Adjusted min/max font sizes
    final double finalLabelSize = labelSize.clamp(11.0, 14.0);
    final double finalValueSize = valueSize.clamp(14.0, 20.0);
    final double finalUnitSize = unitSize.clamp(11.0, 14.0);

    // Smaller border radius
    final borderRadius = screenWidth * 0.03.clamp(15.0, 25.0);

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              color: colorScheme.onPrimaryContainer,
              fontSize: finalLabelSize,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: screenWidth * 0.008),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: finalValueSize,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
              Text(
                ' g',
                style: TextStyle(
                  fontSize: finalUnitSize,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}