import 'package:flutter/material.dart';
import 'package:pizza_calc/utils/recipe_ingredients.dart';
import 'package:pizza_calc/utils/yeast_calc.dart';
import 'package:pizza_calc/utils/yeast_selector.dart';

import 'dart:developer'; // For logging

class IngredientInput extends StatefulWidget {
  const IngredientInput({super.key});

  @override
  IngredientInputState createState() => IngredientInputState();
}

class IngredientInputState extends State<IngredientInput> {
  // State variables to track user inputs
  int _doughBalls = 4;
  int _ballWeight = 250;
  int _hydration = 65;
  double _saltPercentage = 2.0;
  final double _yeastPercentage = 0.3;
  double _rt = 20.0;
  int _rtHours = 4;
  int _ct = 4;
  int _ctHours = 24;
  bool _isMultiStage = false; // Initial state of the switch
  YeastType _yeastType = YeastType.active;

  // Variables for calculated results
  double _flour = 0;
  double _water = 0;
  double _salt = 0;
  double _yeast = 0;

  // Controllers to track user inputs
  late TextEditingController doughBallController;
  late TextEditingController ballWeightController;
  late TextEditingController hydrationController;
  late TextEditingController saltPercentageController;
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
    yeastPercentageController,
    rtController,
    rtHoursController,
    ctController,
    ctHoursController
  ];

  @override
  void initState() {
    super.initState();
    // Initialize controllers for each TextField
    doughBallController = TextEditingController(text: _doughBalls.toString());
    ballWeightController = TextEditingController(text: _ballWeight.toString());
    hydrationController = TextEditingController(text: _hydration.toString());
    saltPercentageController = TextEditingController(text: _saltPercentage.toString());
    yeastPercentageController = TextEditingController(text: _yeastPercentage.toString());
    rtController = TextEditingController(text: _rt.toString());
    rtHoursController = TextEditingController(text: _rtHours.toString());
    ctController = TextEditingController(text: _ct.toString());
    ctHoursController = TextEditingController(text: _ctHours.toString());

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
  _flour = totalWeight / (1 + _hydration / 100 + _saltPercentage / 100);
  _water = _flour * _hydration / 100;
  _salt = _flour * _saltPercentage / 100;

  log("Calculated flour: $_flour, water: $_water, salt: $_salt");

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
    List<Map<String, dynamic>> lookupTable = DatabaseHelper().getCachedLookupTable('active');

    double yeastAmount = await yeastCalc(fermentationSteps, lookupTable, initialYeast: _yeastPercentage);
    // double yeastPercentage = await yeastCalc(fermentationSteps, _yeastPercentage, yeastType, 0.5);
    // _yeast = _flour * yeastPercentage / 100;
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
  setState(() {});
}


  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
      final ingredients = [
        IngredientData(label: 'Flour', value: _flour),
        IngredientData(label: 'Water', value: _water),
        IngredientData(label: 'Salt', value: _salt),
        IngredientData(label: 'Yeast', value: _yeast),
      ];

    return TabBarView(
      children: [
        Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Card(
                  child: SizedBox(
                    width: screenWidth * 0.9,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Dough Details',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Column(
                            children: [
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
                                      border: OutlineInputBorder(
                                      ),
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
                                      border: OutlineInputBorder(
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ]
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Card(
                  child: SizedBox(
                    width: screenWidth * 0.9,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Water',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Column(
                            children: [
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
                                      border: OutlineInputBorder(
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ]
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Card(
                  child:   SizedBox(
                    width: screenWidth * 0.9,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Salt',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Column(
                            children: [
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
                                      border: OutlineInputBorder(
                                      ),
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
                Card(
                  child:   SizedBox(
                    width: screenWidth * 0.9,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Fermentation',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Column(
                            children: [
                              YeastSelector(
                                initialValue: YeastType.active,
                                onYeastTypeChanged: (YeastType newType) {
                                  setState(() {
                                    _yeastType = newType;
                                  });
                                  _calculateIngredients();
                                }
                              ),
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
                                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
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
                                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              _isMultiStage ?
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
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
                                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                              : const SizedBox(height: 0)
                            ]
                          ),
                        ],
                      ),
                    ),
                  )
                ), 
                const Divider(height: 20, thickness: 1,),
                Card(
                  child: SizedBox(
                    width: screenWidth * 0.9,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Final Dough Ingredients',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 10),
                          RecipeIngredients(ingredients: ingredients)
                        ],
                      ),
                    ),
                  ),
                )
              ]
            )
          )
        ),
        const Text('pan pizza page')
      ]
    );
  }
}
