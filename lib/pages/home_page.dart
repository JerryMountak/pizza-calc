import 'package:flutter/material.dart';
import 'package:pizza_calc/utils/ingredient_input.dart';
import 'package:pizza_calc/utils/recipes/recipe_ingredients.dart';
import 'package:pizza_calc/pages/recipes_page.dart';
import 'package:pizza_calc/utils/recipes/recipe.dart';
import 'package:provider/provider.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  HomeTabState createState() => HomeTabState();
}

class HomeTabState extends State<HomeTab> with TickerProviderStateMixin {
  int _selectedTab = 0;
  late TabController _tabController;

  // Define GlobalKeys for each IngredientInput
  final GlobalKey<IngredientInputState> _neapolitanIngredientInputKey = GlobalKey<IngredientInputState>();
  final GlobalKey<IngredientInputState> _panIngredientInputKey = GlobalKey<IngredientInputState>();

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
    IngredientData(label: 'Cold time', value: 24),
    IngredientData(label: 'Preferment percentage', value: 20),
    IngredientData(label: 'Preferment hours', value: 12)
  ];

  static const List<bool> _neapolitanParams = [
    // hasSugar, hasFat, isMultiStage, hasPreferment, 
    // prefermentType(biga/poolish), yeastType(instant/active), 
    // pizzaType (neapolitan/pan)
    false, false, false, false, true, false, true
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
    IngredientData(label: 'Cold time', value: 24),
    IngredientData(label: 'Preferment percentage', value: 20),
    IngredientData(label: 'Preferment hours', value: 12)
  ];

  static const List<bool> _panParams = [
    // hasSugar, hasFat, isMultiStage, hasPreferment, 
    // prefermentType(biga/poolish), yeastType(instant/active), 
    // pizzaType (neapolitan/pan)
    false, false, true, false, false, false, false
  ];

  // A method to save the current recipe
  Future<void> _saveRecipe(String recipeName) async {
    // Check which tab is currently selected
    
    if (_selectedTab == 0) {
      // Neapolitan tab
      PizzaDoughRecipe? neapolitanRecipe = _neapolitanIngredientInputKey.currentState?.getRecipeData();
      if (neapolitanRecipe != null) {
        neapolitanRecipe.name = recipeName;
        await RecipeDatabaseHelper.instance.insertRecipe(neapolitanRecipe);
      }
    } else if (_selectedTab == 1) {
      // Pan Pizza tab
      PizzaDoughRecipe? panRecipe = _panIngredientInputKey.currentState?.getRecipeData();
      if (panRecipe != null) {
        panRecipe.name = recipeName;
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
  void initState() {
    super.initState();
    final recipeProvider = Provider.of<RecipeProvider>(context, listen: false);
    _tabController = TabController(length: 2, vsync: this, initialIndex: recipeProvider.currentTab);
    _tabController.addListener(() {
      recipeProvider.setTab(_tabController.index);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {    
    return Consumer<RecipeProvider>(
      builder: (context, recipeProvider, child) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: const Text("PizzaCalc"),
            bottom: TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Neapolitan'),
                  Tab(text: 'Pan Pizza'),
                ],
                onTap: (index) {
                  recipeProvider.setTab(index);
                  setState(() {
                    _selectedTab = index;
                  });
                },
            )
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              IngredientInput(
                key: _neapolitanIngredientInputKey,
                initialIngredients: _neapolitanIngredients,
                initialParams: _neapolitanParams,
              ),
              IngredientInput(
                key: _panIngredientInputKey,
                initialIngredients: _panIngredients,
                initialParams: _panParams,
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.small(
            tooltip: 'Save Recipe',
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  String recipeName = '';
                  return AlertDialog(
                    title: const Text('Recipe name'),
                    content: TextField(
                      autofocus: true,
                      onChanged: (value) {
                        recipeName = value;
                      },
                      onSubmitted: (value) {
                        _saveRecipe(value);
                        Navigator.of(context).pop();
                      },
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                    ),
                    actions: [
                      TextButton(
                        child: const Text('Cancel'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      TextButton(
                        child: const Text('Save'),
                        onPressed: () {
                          _saveRecipe(recipeName);
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                  );
                },
              );
            },
            child: const Icon(Icons.save),
          ),
        );
      }
    );
  }
}
