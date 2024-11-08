import 'package:flutter/material.dart';
import 'package:pizza_calc/models/pizza_recipe.dart';

class RecipeProvider with ChangeNotifier {
  int _currentIndex = 0;
  int _currentTab = 0;
  PizzaDoughRecipe _neapolitanRecipe = PizzaDoughRecipe(
        name: '',
        doughBalls: 4,
        ballWeight: 250,
        hydration: 65,
        saltPercentage: 2,
        yeastPercentage: 0.3,  
        sugarPercentage: 0,
        fatPercentage: 0,
        roomTemp: 20,
        roomTempHours: 4,
        controlledTemp: 4,
        controlledTempHours: 24,
        isMultiStage: false,
        hasSugar: false,
        hasFat: false,
        yeastType: YeastType.active,
        hasPreferment: false,
        prefermentType: PrefermentType.biga,
        prefermentPercentage: 20,
        prefermentHours: 12,
        hasTangzhong: false,
        pizzaType: PizzaType.neapolitan,
        notes: '',
      );
  
  PizzaDoughRecipe _panRecipe = PizzaDoughRecipe(
        name: '',
        doughBalls: 1,
        ballWeight: 875,
        hydration: 70,
        saltPercentage: 2,
        yeastPercentage: 0.3,  
        sugarPercentage: 0,
        fatPercentage: 2.5,
        roomTemp: 20,
        roomTempHours: 4,
        controlledTemp: 4,
        controlledTempHours: 24,
        isMultiStage: false,
        hasSugar: false,
        hasFat: true,
        yeastType: YeastType.active,
        hasPreferment: false,
        prefermentType: PrefermentType.poolish,
        prefermentPercentage: 20,
        prefermentHours: 12,
        hasTangzhong: false,
        pizzaType: PizzaType.pan,
        notes: '',
      );


  int get currentIndex => _currentIndex;
  int get currentTab => _currentTab;
  PizzaDoughRecipe get neapolitanRecipe => _neapolitanRecipe;
  PizzaDoughRecipe get panRecipe => _panRecipe;

  void setIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  void setTab(int tab) {
    _currentTab = tab;
    notifyListeners();
  }

  void updateRecipe(PizzaDoughRecipe newRecipe) {
    if (newRecipe.pizzaType == PizzaType.neapolitan) {
      _neapolitanRecipe = newRecipe;
    }
    else if (newRecipe.pizzaType == PizzaType.pan) {
      _panRecipe = newRecipe;
    }
    else {
      throw Exception('Invalid pizza type');
    }
    
    // Navigate to homepage
    _currentIndex = 0;

    // Set the current tab based on the pizza type
    if (newRecipe.pizzaType == PizzaType.neapolitan) {
      _currentTab = 0;
    }
    else {
      _currentTab = 1;
    }
    notifyListeners();
  }
}