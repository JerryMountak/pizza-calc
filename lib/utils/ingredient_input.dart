import 'package:flutter/material.dart';
import 'package:pizza_calc/pages/recipes_page.dart';
import 'package:pizza_calc/utils/recipe_ingredients.dart';
import 'package:pizza_calc/utils/yeast/yeast_calc.dart';
import 'package:pizza_calc/utils/yeast/yeast_selector.dart';

import 'dart:developer'; // For logging

class IngredientInput extends StatefulWidget {
  final List<IngredientData> initialIngredients;
  final List<bool> initialParams;

  const IngredientInput({
    super.key,
    required this.initialIngredients,
    required this.initialParams,
  });

  @override
  IngredientInputState createState() => IngredientInputState();
}

class IngredientInputState extends State<IngredientInput> {
  // State variables to track user inputs
  late int _doughBalls;
  late int _ballWeight;
  late int _hydration;
  late double _saltPercentage;
  final double _yeastPercentage = 0.3;
  late double _sugarPercentage;
  late double _fatPercentage;
  late double _rt;
  late int _rtHours;
  late int _ct;
  late int _ctHours;
  late bool _isMultiStage;
  late bool _hasSugar;
  late bool _hasFat;
  late YeastType _yeastType;

  // Variables for calculated results
  double _flour = 0;
  double _water = 0;
  double _salt = 0;
  double _yeast = 0;
  double _sugar = 0;
  double _fat = 0;

  // List of ingredients
  List<IngredientData> ingredients = [
      const IngredientData(label: 'Flour', value: 0),
      const IngredientData(label: 'Water', value: 0),
      const IngredientData(label: 'Salt', value: 0),
      const IngredientData(label: 'Yeast', value: 0),
    ];

  // Recipe State
  late PizzaDoughRecipe _recipe;

  // Controllers to track user inputs
  late TextEditingController doughBallController;
  late TextEditingController ballWeightController;
  late TextEditingController hydrationController;
  late TextEditingController saltPercentageController;
  late TextEditingController sugarController;
  late TextEditingController fatController;
  late TextEditingController yeastPercentageController;
  late TextEditingController rtController;
  late TextEditingController rtHoursController;
  late TextEditingController ctController;
  late TextEditingController ctHoursController;

  late List<TextEditingController> controllers = [
    doughBallController,
    ballWeightController,
    hydrationController,
    saltPercentageController,
    sugarController,
    fatController,
    yeastPercentageController,
    rtController,
    rtHoursController,
    ctController,
    ctHoursController
  ];

  @override
  void initState() {
    super.initState();

    // Initialize local ingredient variables
    _doughBalls = widget.initialIngredients.where(
      (ingredient) => ingredient.label == 'Dough balls'
    ).first.value.toInt();
    _ballWeight = widget.initialIngredients.where(
      (ingredient) => ingredient.label == 'Ball weight'
    ).first.value.toInt();
    _hydration = widget.initialIngredients.where(
      (ingredient) => ingredient.label == 'Hydration'
    ).first.value.toInt();
    _saltPercentage = widget.initialIngredients.where(
      (ingredient) => ingredient.label == 'Salt percentage'
    ).first.value.toDouble();
    _sugarPercentage = widget.initialIngredients.where(
      (ingredient) => ingredient.label == 'Sugar percentage'
    ).first.value.toDouble();
    _fatPercentage = widget.initialIngredients.where(
      (ingredient) => ingredient.label == 'Fat percentage'
    ).first.value.toDouble();
    _rt = widget.initialIngredients.where(
      (ingredient) => ingredient.label == 'Room temperature'
    ).first.value.toDouble();
    _rtHours = widget.initialIngredients.where(
      (ingredient) => ingredient.label == 'Room time'
    ).first.value.toInt();
    _ct = widget.initialIngredients.where(
      (ingredient) => ingredient.label == 'Cold temperature'
    ).first.value.toInt();
    _ctHours = widget.initialIngredients.where(
      (ingredient) => ingredient.label == 'Cold time'
    ).first.value.toInt();

    // Initialize other local variables
    _isMultiStage = widget.initialParams[0];
    _hasSugar = widget.initialParams[1];
    _hasFat = widget.initialParams[2];
    _yeastType = widget.initialParams[3] ? YeastType.instant : YeastType.active;

    // Initialize controllers for each TextField
    doughBallController = TextEditingController(text: _doughBalls.toString());
    ballWeightController = TextEditingController(text: _ballWeight.toString());
    hydrationController = TextEditingController(text: _hydration.toString());
    saltPercentageController = TextEditingController(text: _saltPercentage.toString());
    sugarController = TextEditingController(text: _sugarPercentage.toString());
    fatController = TextEditingController(text: _fatPercentage.toString());
    yeastPercentageController = TextEditingController(text: _yeastPercentage.toString());
    rtController = TextEditingController(text: _rt.toString());
    rtHoursController = TextEditingController(text: _rtHours.toString());
    ctController = TextEditingController(text: _ct.toString());
    ctHoursController = TextEditingController(text: _ctHours.toString());

    // Call the function to calculate the ingredients
    _calculateIngredients();
  }

  @override
  void dispose() {
    // Clean up controllers when the widget is disposed
    for (var controller in controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  // Function to calculate the ingredients with added debug info
  void _calculateIngredients() async {
    // Log the start time
    final startTime = DateTime.now();
    log("Ingredient calculation started at: $startTime");

    // Calculate total dough weight
    int totalWeight = _doughBalls * _ballWeight;
    log("Total dough weight: $totalWeight");

    // Perform ingredient calculations
    _flour = totalWeight / (1 + _hydration / 100 + _saltPercentage / 100 + (_hasSugar ? _sugarPercentage / 100 : 0)  + (_hasFat ? _fatPercentage / 100 : 0));
    _water = _flour * _hydration / 100;
    _salt = _flour * _saltPercentage / 100;
    _sugar = _flour * (_hasSugar ? _sugarPercentage / 100 : 0);
    _fat = _flour * (_hasFat ? _fatPercentage / 100 : 0);

    log("Calculated flour: $_flour, water: $_water, salt: $_salt, sugar: $_sugar, fat: $_fat");

    // Determine yeast type
    String yeastType;
    if (_yeastType == YeastType.active) {
      yeastType = 'active';
    } else if (_yeastType == YeastType.instant) {
      yeastType = 'instant';
    } else {
      throw Exception('Invalid yeast type: $_yeastType');
    }
    log("Yeast type: $yeastType");

    // Start tracking yeast calculation time
    final yeastStartTime = DateTime.now();

    // Calculate yeast
    List<List<double>> fermentationSteps = [];
    if (_isMultiStage) {
      fermentationSteps.add([_ctHours.toDouble(), _ct.toDouble()]);
    }
    fermentationSteps.add([_rtHours.toDouble(), _rt]);

    log("Fermentation steps: $fermentationSteps");

    try {
      await DatabaseHelper().loadLookupTable(yeastType); // or 'instant'
      List<Map<String, dynamic>> lookupTable =
          DatabaseHelper().getCachedLookupTable('active');

      double yeastAmount = await yeastCalc(fermentationSteps, lookupTable,
          initialYeast: _yeastPercentage);
      _yeast = _flour * yeastAmount / 100;

      // Log the yeast calculation details
      log("Yeast percentage: $yeastAmount, Calculated yeast: $_yeast");

      // Log the time taken for yeast calculation
      final yeastEndTime = DateTime.now();
      log("Yeast calculation took: ${yeastEndTime.difference(yeastStartTime).inMilliseconds} ms");
    } catch (e) {
      log("Error during yeast calculation: $e");
    }

    // Notify Flutter to rebuild the UI with the updated values
    setState(() {
      // Update ingredients list
      ingredients = [
        IngredientData(label: "Flour", value: _flour),
        IngredientData(label: "Water", value: _water),
        IngredientData(label: "Salt", value: _salt),
        if (_hasSugar) IngredientData(label: "Sugar", value: _sugar),
        if (_hasFat) IngredientData(label: "Fat", value: _fat),
        IngredientData(label: "Yeast", value: _yeast),
      ];

      // Update recipe state
      _recipe = PizzaDoughRecipe(
        name: '',
        doughBalls: _doughBalls,
        ballWeight: _ballWeight,
        hydration: _hydration,
        saltPercentage: _saltPercentage,
        yeastPercentage: _yeastPercentage,  
        sugarPercentage: _sugarPercentage,
        fatPercentage: _fatPercentage,
        roomTemp: _rt,
        roomTempHours: _rtHours,
        controlledTemp: _ct.toDouble(),
        controlledTempHours: _ctHours,
        isMultiStage: _isMultiStage,
        hasSugar: _hasSugar,
        hasFat: _hasFat,
        yeastType: _yeastType,
      );
    });
  }

  // Function to get the current recipe data
  PizzaDoughRecipe? getRecipeData() {
    // Return the current recipe state
    return _recipe;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Center(
        child: SingleChildScrollView(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      // Dough Details
      Card(
        child: SizedBox(
          width: screenWidth * 0.9,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 5),
                Text(
                  'Dough Details',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 10),
                Column(children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 15.0),
                    child: SizedBox(
                      width: screenWidth * 0.8,
                      child: TextField(
                        controller: doughBallController,
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            _doughBalls = int.parse(value);
                            _calculateIngredients();
                          }
                        },
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'No. of dough balls',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 15.0),
                    child: SizedBox(
                      width: screenWidth * 0.8,
                      child: TextField(
                        controller: ballWeightController,
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            _ballWeight = int.parse(value);
                            _calculateIngredients();
                          }
                        },
                        decoration: const InputDecoration(
                          labelText: 'Ball Weight (g)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ),
                ]),
              ],
            ),
          ),
        ),
      ),
      const SizedBox(height: 10),

      // Hydration
      Card(
        child: SizedBox(
          width: screenWidth * 0.9,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 5),
                Text(
                  'Water',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 10),
                Column(children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 15.0),
                    child: SizedBox(
                      width: screenWidth * 0.8,
                      child: TextField(
                        controller: hydrationController,
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            _hydration = int.parse(value);
                            _calculateIngredients();
                          }
                        },
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Hydration (%)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ),
                ]),
              ],
            ),
          ),
        ),
      ),
      const SizedBox(height: 10),

      // Salt
      Card(
          child: SizedBox(
            width: screenWidth * 0.9,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 5),
                  Text(
                    'Salt',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Column(children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 15.0),
                      child: SizedBox(
                        width: screenWidth * 0.8,
                        child: TextField(
                          controller: saltPercentageController,
                          onChanged: (value) {
                            if (value.isNotEmpty) {
                              _saltPercentage = double.parse(value);
                              _calculateIngredients();
                            }
                          },
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Salt (%)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ),
                  ]
                ),
              ],
            ),
          ),
        )
      ),
      const SizedBox(height: 10),

      // Optional Ingredients
      Card(
        child: SizedBox(
          width: screenWidth * 0.9,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 5),
                Text(
                  'Optional',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 10),
                Column(children: [
                  SwitchListTile(
                    title: const Text('Sugar'),
                    value: _hasSugar,
                    onChanged: (bool value) {
                      setState(() {
                        _hasSugar = value;
                        if (value) {
                          ingredients.add(
                            IngredientData(label: 'Sugar', value: _sugar),
                          );
                          log('Ingredient added: ${ingredients.length}');
                        }
                        else {
                          ingredients.removeWhere((element) => element.label == 'Sugar');
                          log('Ingredient removed:${ingredients.length}');
                        }
                      });
                      _calculateIngredients();
                    },
                    activeColor: Theme.of(context).colorScheme.primary,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
                  ),
                  SwitchListTile(
                    title: const Text('Fat'),
                    value: _hasFat,
                    onChanged: (bool value) {
                      setState(() {
                        _hasFat = value;
                        if (value) {
                          ingredients.add(
                            IngredientData(label: 'Fat', value: _fat),
                          );
                        }
                        else {
                          ingredients.removeWhere((element) => element.label == 'Fat');
                        }
                      });
                      _calculateIngredients();
                    },
                    activeColor: Theme.of(context).colorScheme.primary,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
                  ),
                  _hasSugar
                    ? Padding(
                      padding: const EdgeInsets.only(bottom: 15.0),
                      child: SizedBox(
                        width: screenWidth * 0.8,
                        child: TextField(
                          controller: sugarController,
                          onChanged: (value) {
                            if (value.isNotEmpty) {
                              _sugarPercentage = double.parse(value);
                              _calculateIngredients();
                            }
                          },
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Sugar (%)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    )
                    : const SizedBox(height: 0),
                  _hasFat
                    ? Padding(
                      padding: const EdgeInsets.only(bottom: 15.0),
                      child: SizedBox(
                        width: screenWidth * 0.8,
                        child: TextField(
                          controller: fatController,
                          onChanged: (value) {
                            if (value.isNotEmpty) {
                              _fatPercentage = double.parse(value);
                              _calculateIngredients();
                            }
                          },
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Fat (%)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    )
                    : const SizedBox(height: 0)
                ]),
              ],
            ),
          ),
        )
      ),
      const SizedBox(height: 10),
      
      // Fermentation
      Card(
        child: SizedBox(
          width: screenWidth * 0.9,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 5),
                Text(
                  'Fermentation',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 10),
                Column(children: [
                  YeastSelector(
                      initialValue: YeastType.active,
                      onYeastTypeChanged: (YeastType newType) {
                        setState(() {
                          _yeastType = newType;
                        });
                        _calculateIngredients();
                      }),
                  // Multi-Stage Fermentation Switch
                  SwitchListTile(
                    title: const Text('Multi-Stage Fermentation'),
                    value: _isMultiStage,
                    onChanged: (bool value) {
                      setState(() {
                        _isMultiStage = value;
                      });
                      _calculateIngredients();
                    },
                    activeColor: Theme.of(context).colorScheme.primary,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: rtController,
                            onChanged: (value) {
                              if (value.isNotEmpty) {
                                _rt = double.parse(value);
                                _calculateIngredients();
                              }
                            },
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'RT (°C)',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            controller: rtHoursController,
                            onChanged: (value) {
                              if (value.isNotEmpty) {
                                _rtHours = int.parse(value);
                                _calculateIngredients();
                              }
                            },
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Hours',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _isMultiStage
                      ? Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 8.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: ctController,
                                  onChanged: (value) {
                                    if (value.isNotEmpty) {
                                      _ct = int.parse(value);
                                      _calculateIngredients();
                                    }
                                  },
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'CT (°C)',
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextField(
                                  controller: ctHoursController,
                                  onChanged: (value) {
                                    if (value.isNotEmpty) {
                                      _ctHours = int.parse(value);
                                      _calculateIngredients();
                                    }
                                  },
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'Hours',
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : const SizedBox(height: 0)
                ]),
              ],
            ),
          ),
        )
      ),
      const Divider(height: 20, thickness: 1,),

      // Final Ingredients
      Card(
        child: SizedBox(
          width: screenWidth * 0.9,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 5),
                Text(
                  'Final Dough Ingredients',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 10),
                RecipeIngredients(initialIngredients: ingredients)
              ],
            ),
          ),
        ),
      ),

      const SizedBox(height: 80),
    ])));
  }
}
