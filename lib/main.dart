import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'pages/recipes_page.dart';
import 'pages/settings_page.dart';

import 'package:sqflite_common_ffi/sqflite_ffi.dart';


void main() {
  // Initialize FFI only for desktop (macOS, Windows, Linux)
  // Initialize FFI
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;


  // Avoid errors caused by flutter upgrade.
  // Importing 'package:flutter/widgets.dart' is required.
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PizzaCalc',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'PizzaCalc'),
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
  int _selectedIndex = 0; // Track the selected index

  // List of pages for the navigation
  static const List<Widget> _pages = <Widget>[
    HomeTab(), // Home Page (Neapolitan and Pan Pizza)
    RecipesTab(), // Recipes Page
    SettingsTab(), // Settings Page
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Update the selected index to switch pages
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
          bottom: _selectedIndex == 0 // Only show the TabBar on the Home page
              ? const TabBar(
                  tabs: [
                    Tab(text: 'Neapolitan'),
                    Tab(text: 'Pan Pizza'),
                  ],
                )
              : null, // Hide the TabBar on other pages
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.save),
              tooltip: 'Save Recipe',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Recipe Saved')),
                );
              },
            ),
          ],
        ),
        body: _pages[_selectedIndex], // Display the current page based on selected index
        bottomNavigationBar: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: _onItemTapped, // Change page when a button is tapped
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
}
