import 'package:flutter/material.dart';
import 'package:pizza_calc/services/recipe_db.dart';
import 'package:provider/provider.dart';

import 'package:pizza_calc/models/pizza_recipe.dart';
import 'package:pizza_calc/providers/advanced_provider.dart';
import 'package:pizza_calc/providers/recipe_provider.dart';


// Recipe list page
class RecipesTab extends StatefulWidget {
  const RecipesTab({super.key});

  @override
  RecipesTabState createState() => RecipesTabState();
}

class RecipesTabState extends State<RecipesTab> {
  late Future<List<PizzaDoughRecipe>> _recipesFuture;

  @override
  void initState() {
    super.initState();
    _loadRecipes();
  }

  void _loadRecipes() {
    _recipesFuture = RecipeDatabaseHelper.instance.getAllRecipes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Recipes"),
      ),
      body: FutureBuilder<List<PizzaDoughRecipe>>(
        future: _recipesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No recipes saved'));
          }

          final recipes = snapshot.data!;
          return ListView.builder(
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              final recipe = recipes[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: ListTile(
                  title: Text(
                    recipe.name, 
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    'Balls: ${recipe.doughBalls}x${recipe.ballWeight}g, '
                    'Hydration: ${recipe.hydration}%\n'
                    'RT: ${recipe.roomTempHours}h at ${recipe.roomTemp}°C'
                    '${recipe.isMultiStage 
                      ? ', CT: ${recipe.controlledTempHours}h at ${recipe.controlledTemp}°C' 
                      : ''
                      }'
                  ),
                  leading: Icon(
                    Icons.local_pizza_rounded,
                    color: Theme.of(context).colorScheme.onSurface,
                  ), 
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () async {
                      await RecipeDatabaseHelper.instance.deleteRecipe(recipe.id!);
                      setState(() {
                        _loadRecipes();
                      });
                    },
                  ),
                  onTap: () {
                    if (recipe.hasPreferment) {
                      Provider.of<AdvancedProvider>(context, listen: false).setUsePreferments(true);
                      Provider.of<AdvancedProvider>(context, listen: false).setPrefermentType(recipe.prefermentType);
                    }
                    else {
                      Provider.of<AdvancedProvider>(context, listen: false).setUsePreferments(false);
                      Provider.of<AdvancedProvider>(context, listen: false).setPrefermentType(recipe.prefermentType);
                    }

                    if (recipe.hasTangzhong) {
                      Provider.of<AdvancedProvider>(context, listen: false).setUseTangzhong(true);
                    }
                    else {
                      Provider.of<AdvancedProvider>(context, listen: false).setUseTangzhong(false);
                    }

                    Provider.of<RecipeProvider>(context, listen: false).updateRecipe(recipe);
                  }
                ),
              );
            },
          );
        },
      )
    );
  }
}
