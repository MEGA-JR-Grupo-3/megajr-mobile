import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart'; // Certifique-se de que este caminho está correto

class ThemeSwitch extends StatelessWidget {
  const ThemeSwitch({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Switch(
      value: themeProvider.themeMode == ThemeMode.dark,
      onChanged: (value) {
        themeProvider.toggleTheme(value);
      },
      activeColor:
          Theme.of(
            context,
          ).colorScheme.primary, // Cor quando o switch está ativado
      inactiveThumbColor:
          Theme.of(
            context,
          ).colorScheme.onSurface, // Cor do "polegar" quando inativo
      inactiveTrackColor: Theme.of(context).colorScheme.onSurface.withOpacity(
        0.5,
      ), // Cor da "trilha" quando inativo
    );
  }
}
