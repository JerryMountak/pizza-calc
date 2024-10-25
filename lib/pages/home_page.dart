import 'package:flutter/material.dart';
import 'package:pizza_calc/utils/ingredient_input.dart';
import 'package:pizza_calc/utils/recipe_ingredients.dart';
import 'package:pizza_calc/pages/recipes_page.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  HomeTabState createState() => HomeTabState();
}

class HomeTabState extends State<HomeTab> with TickerProviderStateMixin {
  int _selectedTab = 0;

  // Define GlobalKeys for each IngredientInput
  final GlobalKey<IngredientInputState> _neapolitanIngredientInputKey =
      GlobalKey<IngredientInputState>();
  final GlobalKey<IngredientInputState> _panIngredientInputKey =
      GlobalKey<IngredientInputState>();

  static const List<IngredientData> _neapolitanIngredients = [
    IngredientData(label: 'Dough balls', value: 4),
    IngredientData(label: 'Ball weight', value: 250),
    IngredientData(label: 'Hydration', value: 65),
    IngredientData(label: 'Salt percentage', value: 2),
    IngredientData(label: 'Sugar percentage', value: 0),
    IngredientData(label: 'Fat percentage', value: 0),
    IngredientData(label: 'Room temperature', value: 20),
    IngredientData(label: 'Room time', value: 4),
    IngredientData(label: 'Cold temperature', value: 4),
    IngredientData(label: 'Cold time', value: 24)
  ];

  static const List<bool> _neapolitanParams = [
    // hasSugar, hasFat, isMultiStage, yeastType(instant/active)
    false, false, false, false
  ];

  static const List<IngredientData> _panIngredients = [
    IngredientData(label: 'Dough balls', value: 1),
    IngredientData(label: 'Ball weight', value: 875),
    IngredientData(label: 'Hydration', value: 70),
    IngredientData(label: 'Salt percentage', value: 2),
    IngredientData(label: 'Sugar percentage', value: 0),
    IngredientData(label: 'Fat percentage', value: 2.5),
    IngredientData(label: 'Room temperature', value: 20),
    IngredientData(label: 'Room time', value: 4),
    IngredientData(label: 'Cold temperature', value: 4),
    IngredientData(label: 'Cold time', value: 24)
  ];

  static const List<bool> _panParams = [
    // hasSugar, hasFat, isMultiStage, yeastType(instant/active)
    false, false, true, false
  ];

  // A method to save the current recipe
  Future<void> _saveRecipe() async {
    // Check which tab is currently selected
    if (_selectedTab == 0) {
      // Neapolitan tab
      final neapolitanRecipe =
          _neapolitanIngredientInputKey.currentState?.getRecipeData();
      if (neapolitanRecipe != null) {
        await RecipeDatabaseHelper.instance.insertRecipe(neapolitanRecipe);
      }
    } else if (_selectedTab == 1) {
      // Pan Pizza tab
      final panRecipe = _panIngredientInputKey.currentState?.getRecipeData();
      if (panRecipe != null) {
        await RecipeDatabaseHelper.instance.insertRecipe(panRecipe);
      }
    }
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Recipe saved successfully!'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("PizzaCalc"),
        bottom: TabBar(
            tabs: const [
              Tab(text: 'Neapolitan'),
              Tab(text: 'Pan Pizza'),
            ],
            onTap: (index) {
              setState(() {
                _selectedTab = index;
              });
            }),
      ),
      body: TabBarView(
        // controller: _tabController,
        children: [
          IngredientInput(
            key: _neapolitanIngredientInputKey, // Pass the GlobalKey here
            initialIngredients: _neapolitanIngredients,
            initialParams: _neapolitanParams,
          ),
          IngredientInput(
            key: _panIngredientInputKey, // Pass the GlobalKey here
            initialIngredients: _panIngredients,
            initialParams: _panParams,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.small(
        tooltip: 'Save Recipe',
        onPressed: _saveRecipe, // Call the save method here
        child: const Icon(Icons.save),
      ),
    );
  }
}
