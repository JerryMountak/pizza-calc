import 'package:flutter/material.dart';
import 'package:pizza_calc/utils/yeast/yeast_selector.dart';

enum PizzaType { neapolitan, pan }

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

// Model class for pizza dough recipe
class PizzaDoughRecipe {
  final int? id;
  String name;
  final int doughBalls;
  final int ballWeight;
  final int hydration;
  final double saltPercentage;
  final double yeastPercentage;
  final double? sugarPercentage;
  final double? fatPercentage;
  final double roomTemp;
  final int roomTempHours;
  final double? controlledTemp;
  final int? controlledTempHours;
  final bool isMultiStage;
  final bool hasSugar;
  final bool hasFat;
  final YeastType yeastType;
  final PizzaType pizzaType;
  final String notes;

  PizzaDoughRecipe({
    this.id,
    required this.name,
    required this.doughBalls,
    required this.ballWeight,
    required this.hydration,
    required this.saltPercentage,
    this.yeastPercentage = 0.3,
    this.sugarPercentage,
    this.fatPercentage,
    required this.roomTemp,
    required this.roomTempHours,
    this.controlledTemp,
    this.controlledTempHours,
    required this.isMultiStage,
    required this.hasSugar,
    required this.hasFat,
    required this.yeastType,
    required this.pizzaType,
    this.notes = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'doughBalls': doughBalls,
      'ballWeight': ballWeight,
      'hydration': hydration,
      'saltPercentage': saltPercentage,
      'yeastPercentage': yeastPercentage,
      'sugarPercentage': sugarPercentage,
      'fatPercentage': fatPercentage,
      'roomTemp': roomTemp,
      'roomTempHours': roomTempHours,
      'controlledTemp': controlledTemp,
      'controlledTempHours': controlledTempHours,
      'isMultiStage': isMultiStage ? 1 : 0,
      'hasSugar': hasSugar ? 1 : 0,
      'hasFat': hasFat ? 1 : 0,
      'yeastType': yeastType.index,
      'pizzaType': pizzaType.index,
      'notes': notes,
    };
  }

  factory PizzaDoughRecipe.fromMap(Map<String, dynamic> map) {
    return PizzaDoughRecipe(
      id: map['id'],
      name: map['name'],
      doughBalls: map['doughBalls'],
      ballWeight: map['ballWeight'],
      hydration: map['hydration'],
      saltPercentage: map['saltPercentage'],
      yeastPercentage: map['yeastPercentage'],
      sugarPercentage: map['sugarPercentage'],
      fatPercentage: map['fatPercentage'],
      roomTemp: map['roomTemp'],
      roomTempHours: map['roomTempHours'],
      controlledTemp: map['controlledTemp'],
      controlledTempHours: map['controlledTempHours'],
      isMultiStage: map['isMultiStage'] == 1,
      hasSugar: map['hasSugar'] == 1,
      hasFat: map['hasFat'] == 1,
      yeastType: YeastType.values[map['yeastType']],
      pizzaType: PizzaType.values[map['pizzaType']],
      notes: map['notes'],
    );
  }
}