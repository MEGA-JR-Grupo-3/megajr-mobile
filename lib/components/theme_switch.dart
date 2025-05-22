// lib/components/theme_switch.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_megajr_grupo3/providers/theme_provider.dart';

class ThemeSwitch extends StatelessWidget {
  const ThemeSwitch({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    final bool isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Switch(
      value: isDarkMode,
      onChanged: (bool value) {
        themeProvider.toggleTheme(value);
      },
      activeColor: Theme.of(context).primaryColor,
    );
  }
}
