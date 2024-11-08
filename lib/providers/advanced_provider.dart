import 'package:flutter/material.dart';
import 'package:pizza_calc/models/pizza_recipe.dart';

class AdvancedProvider with ChangeNotifier {
  bool _usePreferments = false;
  PrefermentType _prefermentType = PrefermentType.poolish;
  bool _bowlCompensation = false;
  int _compPercentage = 1;
  bool _useTangzhong = false;

  bool get usePreferments => _usePreferments;
  PrefermentType get prefermentType => _prefermentType;
  bool get bowlCompensation => _bowlCompensation;
  int get compPercentage => _compPercentage;
  bool get useTangzhong => _useTangzhong;

  void setUsePreferments(bool value) {
    _usePreferments = value;
    notifyListeners();
  }

  void setPrefermentType(PrefermentType type) {
    _prefermentType = type;
    notifyListeners();
  }

  void setBowlCompensation(bool value) {
    _bowlCompensation = value;
    notifyListeners();
  }

  void setCompPercentage(int value) {
    _compPercentage = value;
    notifyListeners();
  }

  void setUseTangzhong(bool value) {
    _useTangzhong = value;
    notifyListeners();
  }
}