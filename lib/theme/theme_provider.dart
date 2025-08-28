import 'package:flutter/material.dart';
import 'package:habit_tracker/theme/dark_mode.dart';
import 'package:habit_tracker/theme/light_mode.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeData _themeData = lightMode; // initial theme
  ThemeData get themeData => _themeData; // get current theme
  bool get isDarkMode => _themeData == darkMode; // check if dark mode is active

// set theme
  set themeData(ThemeData theme) {
    _themeData = theme;
    notifyListeners(); // notify listeners about the theme change
  }

  // toggle between light and dark mode
  void toggleTheme(){
    if(_themeData == lightMode){
      themeData = darkMode;
    } else {
      themeData = lightMode;
    }
  }
}
