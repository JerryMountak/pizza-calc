import 'package:flutter/material.dart';
import 'package:pizza_calc/utils/ingredient_input.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  HomeTabState createState() => HomeTabState();
}

class HomeTabState extends State<HomeTab> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: IngredientInput(),
    );
  }
}