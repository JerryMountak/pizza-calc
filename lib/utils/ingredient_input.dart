import 'dart:async';
import 'dart:math';
import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:pizza_calc/services/yeast_db.dart';
import 'package:provider/provider.dart';

import 'package:pizza_calc/models/ingredients.dart';
import 'package:pizza_calc/models/pizza_recipe.dart';
import 'package:pizza_calc/providers/recipe_provider.dart';
import 'package:pizza_calc/providers/advanced_provider.dart';
import 'package:pizza_calc/widgets/recipe_ingredients.dart';
import 'package:pizza_calc/widgets/yeast_selector.dart';
import 'package:pizza_calc/utils/yeast_calc.dart';

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
  late double _yeastPercentage = 0.3;
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
  late bool _hasPreferment;
  late PrefermentType _prefermentType;
  late int _prefermentPercentage;
  late int _prefermentHours;
  late bool _hasTangzhong;
  late PizzaType _pizzaType;

  // Variables for calculated results
  double _flour = 0;
  double _water = 0;
  double _salt = 0;
  double _yeast = 0;
  double _sugar = 0;
  double _fat = 0;
  double _prefermentFlour = 0;
  double _prefermentWater = 0;
  double _prefermentYeast = 0;
  double _tangzhongFlour = 0;
  double _tangzhongWater = 0;
  double _totalFlour = 0;

  // List of ingredients (main dough)
  List<IngredientData> ingredients = [
    const IngredientData(label: 'Flour', value: 0),
    const IngredientData(label: 'Water', value: 0),
    const IngredientData(label: 'Salt', value: 0),
    const IngredientData(label: 'Yeast', value: 0),
  ];

  // List of ingredients (preferment dough)
  List<IngredientData> prefermentIngredients = [
    const IngredientData(label: 'Flour', value: 0),
    const IngredientData(label: 'Water', value: 0),
    const IngredientData(label: 'Yeast', value: 0),
  ];

  // List of ingredients (tangzhong paste)
  List<IngredientData> tangzhongIngredients = [
    const IngredientData(label: 'Flour', value: 0),
    const IngredientData(label: 'Water', value: 0),
  ];

  // Recipe State
  PizzaDoughRecipe? _recipe;

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
  late TextEditingController prefPercentageController;
  late TextEditingController prefHoursController;

  late List<TextEditingController> controllers;

  // Form keys for validation
  final _doughBallsFormKey = GlobalKey<FormState>();
  final _doughBallWeightFormKey = GlobalKey<FormState>();
  final _hydrationFormKey = GlobalKey<FormState>();
  final _saltFormKey = GlobalKey<FormState>();
  final _optionalIngredientsFormKey = GlobalKey<FormState>();
  final _rtFormKey = GlobalKey<FormState>();
  final _rtHoursFormKey = GlobalKey<FormState>();
  final _ctFormKey = GlobalKey<FormState>();
  final _ctHoursFormKey = GlobalKey<FormState>();
  final _prefermentFormKey = GlobalKey<FormState>();


  @override
  void initState() {
    super.initState();

    // Initialize local ingredient variables from widget.initialIngredients
    _doughBalls = widget.initialIngredients
        .firstWhere((i) => i.label == 'Dough balls')
        .value
        .toInt();
    _ballWeight = widget.initialIngredients
        .firstWhere((i) => i.label == 'Ball weight')
        .value
        .toInt();
    _hydration = widget.initialIngredients
        .firstWhere((i) => i.label == 'Hydration')
        .value
        .toInt();
    _saltPercentage = widget.initialIngredients
        .firstWhere((i) => i.label == 'Salt percentage')
        .value
        .toDouble();
    _sugarPercentage = widget.initialIngredients
        .firstWhere((i) => i.label == 'Sugar percentage')
        .value
        .toDouble();
    _fatPercentage = widget.initialIngredients
        .firstWhere((i) => i.label == 'Fat percentage')
        .value
        .toDouble();
    _rt = widget.initialIngredients
        .firstWhere((i) => i.label == 'Room temperature')
        .value
        .toDouble();
    _rtHours = widget.initialIngredients
        .firstWhere((i) => i.label == 'Room time')
        .value
        .toInt();
    _ct = widget.initialIngredients
        .firstWhere((i) => i.label == 'Cold temperature')
        .value
        .toInt();
    _ctHours = widget.initialIngredients
        .firstWhere((i) => i.label == 'Cold time')
        .value
        .toInt();
    _prefermentPercentage = widget.initialIngredients
        .firstWhere((i) => i.label == 'Preferment percentage')
        .value
        .toInt();
    _prefermentHours = widget.initialIngredients
        .firstWhere((i) => i.label == 'Preferment hours')
        .value
        .toInt();

    // Initialize other local variables from widget.initialParams
    _isMultiStage = widget.initialParams[0];
    _hasSugar = widget.initialParams[1];
    _hasFat = widget.initialParams[2];
    _hasPreferment = widget.initialParams[3];
    _hasTangzhong = widget.initialParams[4];
    _prefermentType = widget.initialParams[5] ? PrefermentType.biga : PrefermentType.poolish;
    _yeastType = widget.initialParams[6] ? YeastType.instant : YeastType.active;
    _pizzaType = widget.initialParams[7] ? PizzaType.neapolitan : PizzaType.pan;

    // Initialize controllers
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
    prefPercentageController = TextEditingController(text: _prefermentPercentage.toString());
    prefHoursController = TextEditingController(text: _prefermentHours.toString());

    // Initialize controllers list
    controllers = [
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
      ctHoursController,
      prefPercentageController,
      prefHoursController,
    ];

    _calculateIngredients();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    PizzaDoughRecipe recipe;
    if (Provider.of<RecipeProvider>(context).currentTab == 0) {
      recipe = Provider.of<RecipeProvider>(context).neapolitanRecipe;
    } else {
      recipe = Provider.of<RecipeProvider>(context).panRecipe;
    }

    _loadRecipe(recipe);
  }

  void _loadRecipe(PizzaDoughRecipe recipe) {
    setState(() {
      // Update state variables
      _doughBalls = recipe.doughBalls;
      _ballWeight = recipe.ballWeight;
      _hydration = recipe.hydration;
      _saltPercentage = recipe.saltPercentage;
      _yeastPercentage = recipe.yeastPercentage;
      _sugarPercentage = recipe.sugarPercentage ?? 0.0;
      _fatPercentage = recipe.fatPercentage ?? 0.0;
      _rt = recipe.roomTemp;
      _rtHours = recipe.roomTempHours;
      _ct = recipe.controlledTemp?.toInt() ?? 0;
      _ctHours = recipe.controlledTempHours ?? 0;
      _isMultiStage = recipe.isMultiStage;
      _hasSugar = recipe.hasSugar;
      _hasFat = recipe.hasFat;
      _yeastType = recipe.yeastType;
      _hasPreferment = recipe.hasPreferment;
      _prefermentType = recipe.prefermentType;
      _hasTangzhong = recipe.hasTangzhong;
      _pizzaType = recipe.pizzaType;

      // Update text controllers
      doughBallController.text = recipe.doughBalls.toString();
      ballWeightController.text = recipe.ballWeight.toString();
      hydrationController.text = recipe.hydration.toString();
      saltPercentageController.text = recipe.saltPercentage.toString();
      yeastPercentageController.text = recipe.yeastPercentage.toString();
      sugarController.text = (recipe.sugarPercentage ?? 0.0).toString();
      fatController.text = (recipe.fatPercentage ?? 0.0).toString();
      rtController.text = recipe.roomTemp.toString();
      rtHoursController.text = recipe.roomTempHours.toString();
      ctController.text = (recipe.controlledTemp ?? 0).toString();
      ctHoursController.text = (recipe.controlledTempHours ?? 0).toString();

      // Update recipe state
      _recipe = recipe;
    });

    _calculateIngredients();
  }

  @override
  void dispose() {
    for (var controller in controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  // Function to calculate the ingredients with added debug info
  void _calculateIngredients() async {
    // Calculate total dough weight
    int totalWeight = _doughBalls * _ballWeight;

    // Add bowl compensation if enabled
    if (Provider.of<AdvancedProvider>(context, listen: false)
        .bowlCompensation) {
      dev.log("~~~~~~~ Adding bowl compensation ~~~~~~~");
      double totalWeightDouble = totalWeight.toDouble();
      totalWeightDouble = totalWeight * (1 + Provider.of<AdvancedProvider>(context, listen: false).compPercentage /100);
      totalWeight = totalWeightDouble.toInt();
    }
    dev.log("Total dough weight: $totalWeight");

    // Perform ingredient calculations
    _flour = totalWeight / 
    (
      1 + _hydration / 100 + 
      _saltPercentage / 100 + 
      (_hasSugar ? _sugarPercentage / 100 : 0) +
      (_hasFat ? _fatPercentage / 100 : 0)
    );
    _totalFlour = _flour;
    _water = _flour * _hydration / 100;
    _salt = _flour * _saltPercentage / 100;
    _sugar = _flour * (_hasSugar ? _sugarPercentage / 100 : 0);
    _fat = _flour * (_hasFat ? _fatPercentage / 100 : 0);

    // Calculate tangzhong ingredients if needed
    _hasTangzhong = Provider.of<AdvancedProvider>(context, listen: false).useTangzhong;
    if (_hasTangzhong) {
      // Raise hydration to 75%
      _hydration = 75;

      _flour = totalWeight /
      (
        1 + _hydration / 100 +
        _saltPercentage / 100 +
        (_hasSugar ? _sugarPercentage / 100 : 0) +
        (_hasFat ? _fatPercentage / 100 : 0)
      );
      _totalFlour = _flour;
      _water = _flour * _hydration / 100;
      _salt = _flour * _saltPercentage / 100;
      _sugar = _flour * (_hasSugar ? _sugarPercentage / 100 : 0);
      _fat = _flour * (_hasFat ? _fatPercentage / 100 : 0);

      dev.log("Raised hydration to 75%\nNew totals: flour: $_flour, water: $_water, salt: $_salt, sugar: $_sugar, fat: $_fat");

      // Calculate tangzhong ingredients
      _tangzhongFlour = _flour * 0.05;
      _tangzhongWater = _tangzhongFlour * 5;
      dev.log("Tangzhong ingredients: flour: $_tangzhongFlour, water: $_tangzhongWater");

      // Remove tangzhong ingredients from total flour
      _flour -= _tangzhongFlour;
      _water -= _tangzhongWater;
      dev.log("Ingredients after Tangzhong: flour: $_flour, water: $_water, salt: $_salt, sugar: $_sugar, fat: $_fat");
    }

    // Calculate preferment ingredients if needed
    _hasPreferment = Provider.of<AdvancedProvider>(context, listen: false).usePreferments;
    _prefermentType = Provider.of<AdvancedProvider>(context, listen: false).prefermentType;
    if (_hasPreferment) {
      _prefermentFlour = _flour * _prefermentPercentage / 100;
      _prefermentWater = (_prefermentType == PrefermentType.biga)
          ? _prefermentFlour * 0.5
          : _prefermentFlour;

      // Remove preferment ingredients from total flour
      _flour -= _prefermentFlour;
      _water -= _prefermentWater;
    }

    dev.log("Calculated flour: $_flour, water: $_water, salt: $_salt, sugar: $_sugar, fat: $_fat");
    if (_hasPreferment) {
      dev.log("Calculated preferment flour: $_prefermentFlour, water: $_prefermentWater");
    }

    // Determine yeast type
    String yeastType = _yeastType == YeastType.active ? 'active' : 'instant';
    dev.log("Yeast type: $yeastType");

    // Calculate yeast
    List<List<double>> fermentationSteps = [];
    if (_isMultiStage) {
      fermentationSteps.add([_ctHours.toDouble(), _ct.toDouble()]);
    }
    fermentationSteps.add([_rtHours.toDouble(), _rt]);

    dev.log("Fermentation steps: $fermentationSteps");

    try {
      await DatabaseHelper().loadLookupTable(yeastType);
      // List<Map<String, dynamic>> lookupTable = DatabaseHelper().getCachedLookupTable('active');
      List<Map<String, dynamic>> lookupTable = DatabaseHelper().getCachedLookupTable(yeastType);

      double yeastAmount = await yeastCalc(fermentationSteps, lookupTable, initialYeast: _yeastPercentage);
      _yeast = _totalFlour * yeastAmount / 100;

      if (_hasPreferment) {
        if (_prefermentType == PrefermentType.biga) {
          _prefermentYeast = _prefermentFlour * 0.003;
        } else {
          _prefermentYeast = _prefermentFlour * prefermentYeastCalc(_prefermentHours.toDouble());
        }
        _yeast = max(0, _yeast - _prefermentYeast);
        _yeast -= _prefermentYeast;
      }

      dev.log("Yeast percentage: $yeastAmount, Calculated yeast: $_yeast");
      if (_hasPreferment) {
        dev.log("Calculated preferment yeast: $_prefermentYeast");
      }
    } catch (e) {
      dev.log("Error during yeast calculation: $e");
    }

    if (!mounted) return; // Check if the widget is still mounted

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

      if (_hasTangzhong) {
        tangzhongIngredients = [
          IngredientData(label: "Flour", value: _tangzhongFlour),
          IngredientData(label: "Water", value: _tangzhongWater),
        ];
      }

      if (_hasPreferment) {
        prefermentIngredients = [
          IngredientData(label: "Flour", value: _prefermentFlour),
          IngredientData(label: "Water", value: _prefermentWater),
          IngredientData(label: "Yeast", value: _prefermentYeast),
        ];
      }

      // Update recipe state
      _recipe = PizzaDoughRecipe(
        name: _recipe?.name ?? '',
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
        hasPreferment: Provider.of<AdvancedProvider>(context, listen: false).usePreferments,
        prefermentType: Provider.of<AdvancedProvider>(context, listen: false).prefermentType,
        prefermentPercentage: _prefermentPercentage,
        prefermentHours: _prefermentHours,
        hasTangzhong: Provider.of<AdvancedProvider>(context, listen: false).useTangzhong,
        pizzaType: _pizzaType,
      );
    });
  }

  // Function to get the current recipe data
  PizzaDoughRecipe? getRecipeData() {
    return _recipe;
  }

  // Implement debouncing for stalling text field changes
  Timer? _debounce;

  void _onInputChanged(String value, num Function(String) parseFunction,
      void Function(num) updateVariable) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (value.isNotEmpty) {
        num parsedValue = parseFunction(value);
        updateVariable(parsedValue);
        _calculateIngredients();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Consumer<AdvancedProvider>(
      builder: (context, advancedProvider, child) {
        return Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Dough Details
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: Card(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
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
                                  child: Form(
                                    key: _doughBallsFormKey,
                                    child: TextFormField(
                                      controller: doughBallController,
                                      onChanged: (value) {
                                        if (_doughBallsFormKey.currentState?.validate() == true) {
                                          _onInputChanged(value, int.parse,
                                            (value) => _doughBalls = value.toInt());
                                        }
                                      },
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(
                                        labelText: 'No. of dough balls',
                                        border: OutlineInputBorder(),
                                        errorMaxLines: 2,
                                      ),
                                      // trigger validation as soon as this field value has been changed
                                      autovalidateMode: AutovalidateMode.onUserInteraction,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Dough balls cannot be empty';
                                        }
                                        final int? doughBalls = int.tryParse(value);
                                        if (doughBalls == null) {
                                          return 'Please enter a valid integer';
                                        }
                                        if (doughBalls <= 0) {
                                          return 'Number of dough balls must be greater than zero';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 15.0),
                                child: SizedBox(
                                  width: screenWidth * 0.8,
                                  child: Form(
                                    key: _doughBallWeightFormKey,
                                    child: TextFormField(
                                      controller: ballWeightController,
                                      onChanged: (value) {
                                        if (_doughBallWeightFormKey.currentState?.validate() == true) {
                                          _onInputChanged(value, int.parse,
                                              (value) => _ballWeight = value.toInt());
                                        }
                                      },
                                      decoration: const InputDecoration(
                                        labelText: 'Ball Weight (g)',
                                        border: OutlineInputBorder(),
                                        errorMaxLines: 2,
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Dough ball weight cannot be empty';
                                        }
                                        final int? doughBallWeight = int.tryParse(value);
                                        if (doughBallWeight == null || doughBallWeight <= 0) {
                                          return 'Dough ball weight must be a positive integer';  
                                        }
                                        if (doughBallWeight <= 0) {
                                          return 'Number of dough balls must be greater than zero';
                                        }
                                        return null;
                                      },
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
                ),

                // Hydration
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: Card(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
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
                                  child: Form(
                                    key: _hydrationFormKey,
                                    child: TextFormField(
                                      controller: hydrationController,
                                      onChanged: (value) {
                                        if (_hydrationFormKey.currentState?.validate() == true) {
                                          _onInputChanged(value, int.parse,
                                            (value) => _hydration = value.toInt());
                                        }
                                      },
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(
                                        labelText: 'Hydration (%)',
                                        border: OutlineInputBorder(),
                                        errorMaxLines: 2,
                                      ),
                                      // trigger validation as soon as this field value has been changed
                                      autovalidateMode: AutovalidateMode.onUserInteraction,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Hydration cannot be empty';
                                        }
                                        final int? hydration = int.tryParse(value);
                                        if (hydration == null || hydration <= 0) {
                                          return 'Hydration must be a positive integer';  
                                        }
                                        if (_hasTangzhong && hydration < 75) {
                                          return 'Hydration must be at least 75% when using Tangzhong';
                                        }
                                        return null;
                                      },
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
                ),

                // Salt
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: Card(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
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
                                  child: Form(
                                    key: _saltFormKey,
                                    child: TextFormField(
                                      controller: saltPercentageController,
                                      onChanged: (value) {
                                        if (_saltFormKey.currentState?.validate() == true) {
                                          _onInputChanged(
                                              value,
                                              double.parse,
                                              (value) =>
                                                  _saltPercentage = value.toDouble());
                                        }
                                      },
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(
                                        labelText: 'Salt (%)',
                                        border: OutlineInputBorder(),
                                        errorMaxLines: 2,
                                      ),
                                      // trigger validation as soon as this field value has been changed
                                      autovalidateMode: AutovalidateMode.onUserInteraction,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Salt cannot be empty';
                                        }
                                        final num? saltPercentage = num.tryParse(value);
                                        if (saltPercentage! <= 0) {
                                          return 'Salt percentage must be greater than zero';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ]),
                          ],
                        ),
                      ),
                    )
                  ),
                ),

                // Optional Ingredients
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: Card(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
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
                                      dev.log(
                                          'Ingredient added: ${ingredients.length}');
                                    } else {
                                      ingredients.removeWhere(
                                          (element) => element.label == 'Sugar');
                                      dev.log(
                                          'Ingredient removed:${ingredients.length}');
                                    }
                                  });
                                  _calculateIngredients();
                                },
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
                                    } else {
                                      ingredients.removeWhere(
                                          (element) => element.label == 'Fat');
                                    }
                                  });
                                  _calculateIngredients();
                                },
                                contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
                              ),
                              _hasSugar
                                  ? Padding(
                                      padding: const EdgeInsets.only(bottom: 15.0),
                                      child: SizedBox(
                                        width: screenWidth * 0.8,
                                        child: Form(
                                          key: _optionalIngredientsFormKey,
                                          child: TextFormField(
                                            controller: sugarController,
                                            onChanged: (value) {
                                              if (_optionalIngredientsFormKey.currentState?.validate() == true) {
                                                _onInputChanged(
                                                    value,
                                                    double.parse,
                                                    (value) => _sugarPercentage =
                                                        value.toDouble());
                                              }
                                            },
                                            keyboardType: TextInputType.number,
                                            decoration: const InputDecoration(
                                              labelText: 'Sugar (%)',
                                              border: OutlineInputBorder(),
                                              errorMaxLines: 2,
                                            ),
                                            // trigger validation as soon as this field value has been changed
                                            autovalidateMode: AutovalidateMode.onUserInteraction,
                                            validator: (value) {
                                              if (value == null || value.isEmpty) {
                                                return 'Sugar percentage cannot be empty';
                                              }
                                              final num? sugarPercentage = num.tryParse(value);
                                              if (sugarPercentage! <= 0) {
                                                return 'Sugar percentage must be greater than zero';
                                              }
                                              return null;
                                            },
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
                                        child: Form(
                                          key: _optionalIngredientsFormKey,
                                          child: TextFormField(
                                            controller: fatController,
                                            onChanged: (value) {
                                              if (_optionalIngredientsFormKey.currentState?.validate() == true) {
                                                _onInputChanged(
                                                    value,
                                                    double.parse,
                                                    (value) => _fatPercentage =
                                                        value.toDouble());
                                              }
                                            },
                                            keyboardType: TextInputType.number,
                                            decoration: const InputDecoration(
                                              labelText: 'Fat (%)',
                                              border: OutlineInputBorder(),
                                              errorMaxLines: 2,
                                            ),
                                            // trigger validation as soon as this field value has been changed
                                            autovalidateMode: AutovalidateMode.onUserInteraction,
                                            validator : (value) {
                                              if (value == null || value.isEmpty) {
                                                return 'Fat percentage cannot be empty';
                                              }
                                              final num? fatPercentage = num.tryParse(value);
                                              if (fatPercentage! <= 0) {
                                                return 'Fat percentage must be greater than zero';
                                              }
                                              return null;
                                            },
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
                ),

                // Fermentation
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: Card(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
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
                                contentPadding:
                                    const EdgeInsets.symmetric(horizontal: 20.0),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Form(
                                        key: _rtFormKey,
                                        child: TextFormField(
                                          controller: rtController,
                                          onChanged: (value) {
                                            if (_rtFormKey.currentState?.validate() == true) {
                                              _onInputChanged(value, double.parse,
                                                  (value) => _rt = value.toDouble());
                                            }
                                          },
                                          keyboardType: TextInputType.number,
                                          decoration: const InputDecoration(
                                            labelText: 'RT (°C)',
                                            border: OutlineInputBorder(),
                                            errorMaxLines: 2,
                                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                          ),
                                          // trigger validation as soon as this field value has been changed
                                          autovalidateMode: AutovalidateMode.onUserInteraction,
                                          validator: (value) {
                                              if (value == null || value.isEmpty) {
                                                return 'Temperature cannot be empty';
                                              }

                                              // Check if the value is a valid number
                                              final double? parsedValue = double.tryParse(value);
                                              if (parsedValue == null) {
                                                return 'Please enter a valid number';
                                              }

                                              // Check if the value is within the specified range
                                              if (parsedValue < 15.0 || parsedValue > 25.0) {
                                                return 'Temperature must be between 4.0 and 8.0°C';
                                              }

                                              // Check if the number is either an integer or has a .5 decimal precision
                                              if (parsedValue % 1 != 0 && (parsedValue * 10) % 5 != 0) {
                                                return 'Temperature must be a whole number or have .5 precision';
                                              }

                                              return null;
                                            },
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Form(
                                        key: _rtHoursFormKey,
                                        child: TextFormField(
                                          controller: rtHoursController,
                                          onChanged: (value) {
                                            if (_rtHoursFormKey.currentState?.validate() == true) {
                                              _onInputChanged(value, int.parse,
                                                  (value) => _rtHours = value.toInt());
                                            }
                                          },
                                          keyboardType: TextInputType.number,
                                          decoration: const InputDecoration(
                                            labelText: 'Hours',
                                            border: OutlineInputBorder(),
                                            errorMaxLines: 2,
                                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                          ),
                                          // trigger validation as soon as this field value has been changed
                                          autovalidateMode: AutovalidateMode.onUserInteraction,
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return 'Proofing hours cannot be empty';
                                            }
                                        
                                            // Check if the value is a valid number
                                            final int? parsedValue = int.tryParse(value);
                                            if (parsedValue == null) {
                                              return 'Please enter a valid integer';
                                            }
                                        
                                            // Check if the value is within the specified range
                                            if (parsedValue < 2 || parsedValue > 24) {
                                              return 'Proofing hours must be between 2 and 24';
                                            }
                                        
                                            return null;
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              _isMultiStage
                                ? Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Form(
                                            key: _ctFormKey,
                                            child: TextFormField(
                                              controller: ctController,
                                              onChanged: (value) {
                                                if (_ctFormKey.currentState?.validate() == true) {
                                                  _onInputChanged(value, int.parse,
                                                      (value) => _ct = value.toInt());
                                                }
                                              },
                                              keyboardType: TextInputType.number,
                                              decoration: const InputDecoration(
                                                labelText: 'CT (°C)',
                                                border: OutlineInputBorder(),
                                                errorMaxLines: 2,
                                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                              ),
                                              validator: (value) {
                                                if (value == null || value.isEmpty) {
                                                  return 'Temperature cannot be empty';
                                                }
                                            
                                                // Check if the value is a valid number
                                                final double? parsedValue = double.tryParse(value);
                                                if (parsedValue == null) {
                                                  return 'Please enter a valid number';
                                                }
                                            
                                                // Check if the value is within the specified range
                                                if (parsedValue < 4.0 || parsedValue > 8.0) {
                                                  return 'Temperature must be between 4.0 and 8.0°C';
                                                }
                                            
                                                // Check if the number is either an integer or has a .5 decimal precision
                                                if (parsedValue % 1 != 0 && (parsedValue * 10) % 5 != 0) {
                                                  return 'Temperature must be a whole number or have .5 precision';
                                                }
                                            
                                                return null;
                                              },
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Form(
                                            key: _ctHoursFormKey,
                                            child: TextFormField(
                                              controller: ctHoursController,
                                              onChanged: (value) {
                                                if (_ctHoursFormKey.currentState?.validate() == true) {
                                                  _onInputChanged(
                                                      value,
                                                      int.parse,
                                                      (value) =>
                                                          _ctHours = value.toInt());
                                                }
                                              },
                                              keyboardType: TextInputType.number,
                                              decoration: const InputDecoration(
                                                labelText: 'Hours',
                                                border: OutlineInputBorder(),
                                                errorMaxLines: 2,
                                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                              ),
                                              validator: (value) {
                                                if (value == null || value.isEmpty) {
                                                  return 'Proofing hours cannot be empty';
                                                }
                                            
                                                // Check if the value is a valid number
                                                final int? parsedValue = int.tryParse(value);
                                                if (parsedValue == null) {
                                                  return 'Please enter a valid number';
                                                }
                                            
                                                // Check if the value is within the specified range
                                                if (parsedValue < 16 || parsedValue > 96) {
                                                  return 'Proofing hours must be between 16 and 96';
                                                }
                                            
                                                return null;
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : const SizedBox(height: 0),
                              advancedProvider.usePreferments
                                ? Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20.0, vertical: 8.0),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(advancedProvider
                                            .prefermentType.displayName),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Form(
                                                key: _prefermentFormKey,
                                                child: TextFormField(
                                                  controller: prefPercentageController,
                                                  onChanged: (value) {
                                                    if (_prefermentFormKey.currentState?.validate() == true) {
                                                      _onInputChanged(
                                                          value,
                                                          int.parse,
                                                          (value) =>
                                                              _prefermentPercentage =
                                                                  value.toInt());
                                                    }
                                                  },
                                                  keyboardType: TextInputType.number,
                                                  decoration: const InputDecoration(
                                                    labelText: 'Preferment (%)',
                                                    border: OutlineInputBorder(),
                                                    errorMaxLines: 2,
                                                    contentPadding: EdgeInsets.symmetric(horizontal: 12,vertical: 8),
                                                  ),
                                                  // trigger validation as soon as this field value has been changed
                                                  autovalidateMode: AutovalidateMode.onUserInteraction,
                                                  validator: (value) {
                                                    if (value == null || value.isEmpty) {
                                                      return 'Preferment percentage cannot be empty';
                                                    }
                                                
                                                    // Check if the value is a valid number
                                                    final int? parsedValue = int.tryParse(value);
                                                    if (parsedValue == null) {
                                                      return 'Please enter a valid integer';
                                                    }
                                                
                                                    // Check if the value is within the specified range
                                                    if (parsedValue < 5 || parsedValue > 50) {
                                                      return 'Preferment percentage must be between 5 and 50%';
                                                    }
                                                
                                                    return null;
                                                  },
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: Form(
                                                key: _prefermentFormKey,
                                                child: TextFormField(
                                                  controller: prefHoursController,
                                                  onChanged: (value) {
                                                    if (_prefermentFormKey.currentState?.validate() == true) {
                                                      _onInputChanged(
                                                          value,
                                                          int.parse,
                                                          (value) => _prefermentHours =
                                                              value.toInt());
                                                    }
                                                  },
                                                  keyboardType: TextInputType.number,
                                                  decoration: const InputDecoration(
                                                    labelText: 'Hours',
                                                    border: OutlineInputBorder(),
                                                    errorMaxLines: 2,
                                                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                                  ),
                                                  // trigger validation as soon as this field value has been changed
                                                  autovalidateMode: AutovalidateMode.onUserInteraction,
                                                  validator: (value) {
                                                    if (value == null || value.isEmpty) {
                                                      return 'Preferment proofing hours cannot be empty';
                                                    }
                                                
                                                    // Check if the value is a valid number
                                                    final int? parsedValue = int.tryParse(value);
                                                    if (parsedValue == null) {
                                                      return 'Please enter a valid number';
                                                    }
                                                
                                                    // Check if the value is within the specified range
                                                    if (parsedValue < 3 || parsedValue > 13) {
                                                      return 'Preferment proofing hours must be between 3 and 13';
                                                    }
                                                    return null;
                                                  },
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ))
                                : const SizedBox(height: 0),
                            ]),
                          ],
                        ),
                      ),
                    )
                  ),
                ),

                // Final Ingredients
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Card(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
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
                            _hasPreferment
                              ? Text(
                                  advancedProvider.prefermentType.displayName,
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                    fontSize: 14,
                                  ),
                                )
                              : const SizedBox(height: 0),
                            _hasPreferment
                              ? RecipeIngredients(
                                  initialIngredients: prefermentIngredients)
                              : const SizedBox(height: 0),
                            _hasPreferment
                              ? Divider(
                                  indent: 16,
                                  endIndent: 16,
                                  color: Theme.of(context).colorScheme.outlineVariant,
                                )
                              : const SizedBox(height: 0),
                            advancedProvider.useTangzhong
                              ? Text(
                                  'Tangzhong',
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                    fontSize: 14,
                                  ),
                                )
                              : const SizedBox(height: 0),
                            advancedProvider.useTangzhong
                              ? RecipeIngredients(
                                  initialIngredients: tangzhongIngredients)
                              : const SizedBox(height: 0),
                            advancedProvider.useTangzhong
                              ? Divider(
                                  indent: 16,
                                  endIndent: 16,
                                  color: Theme.of(context).colorScheme.outlineVariant,
                                )
                              : const SizedBox(height: 0),
                            (_hasPreferment || advancedProvider.useTangzhong)
                              ? Text(
                                  'Main Dough',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onSurface,
                                    fontSize: 14,
                                  ),
                                )
                              : const SizedBox(height: 0),
                            RecipeIngredients(initialIngredients: ingredients)
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 80),
              ]
            )
          )
        );
      }
    );
  }
}
