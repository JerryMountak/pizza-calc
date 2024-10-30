import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pizza_calc/utils/recipes/recipe.dart';
import 'package:pizza_calc/utils/theme.dart';
import 'package:provider/provider.dart';
import 'pages/home_page.dart';
import 'pages/recipes_page.dart';
import 'pages/settings_page.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';


void main() {
  if (kIsWeb) {
    // Initialize FFI for web use
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // Avoid errors caused by flutter upgrade.
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => RecipeProvider())
      ],
      child: const MyApp()
    )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static final _defaultLightColorScheme =
    ColorScheme.fromSeed(seedColor: Colors.deepPurple);

  static final _defaultDarkColorScheme = 
    ColorScheme.fromSeed(seedColor: Colors.deepPurple, brightness: Brightness.dark);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return DynamicColorBuilder(
          builder: (lightColorScheme, darkColorScheme) {
            final lightScheme = themeProvider.useDynamicColors
                ? (lightColorScheme ?? _defaultLightColorScheme)
                : _defaultLightColorScheme;
            final darkScheme = themeProvider.useDynamicColors
                ? (darkColorScheme ?? _defaultDarkColorScheme)
                : _defaultDarkColorScheme;

            return MaterialApp(
              title: 'PizzaCalc',
              theme: ThemeData(
                useMaterial3: true,
                colorScheme: lightScheme,
              ),
              darkTheme: ThemeData(
                useMaterial3: true,
                colorScheme: darkScheme,
              ),
              themeMode: themeProvider.themeMode,
              home: const MyHomePage(title: 'PizzaCalc'),
            );
          },
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
              indicatorColor: Theme.of(context).colorScheme.outline,
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
