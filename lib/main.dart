import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:pizza_calc/providers/advanced_provider.dart';
import 'package:pizza_calc/providers/recipe_provider.dart';
import 'package:pizza_calc/providers/theme_provider.dart';

import 'screens/home_page.dart';
import 'screens/recipes_page.dart';
import 'screens/settings_page.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  if (kIsWeb || Platform.isWindows) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // Pre-load theme state
  final themeState = await ThemeProvider.initializeTheme();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ThemeProvider()..initializeFromState(themeState)
        ),
        ChangeNotifierProvider(create: (_) => RecipeProvider()),
        ChangeNotifierProvider(create: (_) => AdvancedProvider()),
      ],
      child: const MyApp()
    )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static final _defaultLightColorScheme = ColorScheme.fromSeed(
    seedColor: Colors.deepPurple
  );
  static final _defaultDarkColorScheme = ColorScheme.fromSeed(
    seedColor: Colors.deepPurple, 
    brightness: Brightness.dark
  );

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final lightScheme = themeProvider.useDynamicColors
            ? (themeProvider.lightDynamic ?? _defaultLightColorScheme)
            : _defaultLightColorScheme;
        final darkScheme = themeProvider.useDynamicColors
            ? (themeProvider.darkDynamic ?? _defaultDarkColorScheme)
            : _defaultDarkColorScheme;

        return MaterialApp(
          title: 'PizzaCalc',
          theme: ThemeData(
            pageTransitionsTheme: const PageTransitionsTheme(
              builders: <TargetPlatform, PageTransitionsBuilder>{
                TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
              },
            ),
            useMaterial3: true,
            colorScheme: lightScheme,
          ),
          darkTheme: ThemeData(
            pageTransitionsTheme: const PageTransitionsTheme(
              builders: <TargetPlatform, PageTransitionsBuilder>{
                TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
              },
            ),
            useMaterial3: true,
            colorScheme: darkScheme,
          ),
          themeMode: themeProvider.themeMode,
          home: const MyHomePage(title: 'PizzaCalc'),
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // List of pages for the navigation
  static const List<Widget> _pages = <Widget>[
    HomeTab(),
    RecipesTab(),
    SettingsTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<RecipeProvider>(
      builder: (context, recipeProvider, child) {
        return DefaultTabController(
          length: 2,
          child: Scaffold(
            body: _pages[recipeProvider.currentIndex],
            bottomNavigationBar: NavigationBar(
              selectedIndex: recipeProvider.currentIndex,
              onDestinationSelected: recipeProvider.setIndex,
              backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
              indicatorColor: Theme.of(context).colorScheme.secondaryContainer,
              destinations: const <NavigationDestination>[
                NavigationDestination(
                  icon: Icon(Icons.home_filled),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.receipt_rounded),
                  label: 'Recipes',
                ),
                NavigationDestination(
                  icon: Icon(Icons.settings),
                  label: 'Settings',
                ),
              ],
            ),
          ),
        );
      }
    );
  }
}
