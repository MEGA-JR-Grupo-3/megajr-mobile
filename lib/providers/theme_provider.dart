// lib/providers/theme_provider.dart
import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system; // Ou ThemeMode.light

  ThemeMode get themeMode => _themeMode;

  // Modifique o método toggleTheme para aceitar um booleano
  // 'isDarkMode' será true se o switch estiver ligado (indicando modo escuro)
  void toggleTheme(bool isDarkMode) {
    _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  // Opcional: Você pode manter o 'setThemeMode' se precisar definir o tema explicitamente em outros lugares
  void setThemeMode(ThemeMode mode) {
    if (_themeMode != mode) {
      _themeMode = mode;
      notifyListeners();
    }
  }
}
