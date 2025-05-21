// lib/components/theme_switch.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_megajr_grupo3/providers/theme_provider.dart';

class ThemeSwitch extends StatelessWidget {
  final AlignmentGeometry alignment; // For fixed top-5 right-5 equivalent
  final EdgeInsetsGeometry padding;
  final Widget? content; // Optional content to display next to the icon

  const ThemeSwitch({
    super.key,
    this.alignment = Alignment.topRight, // Default alignment
    this.padding = const EdgeInsets.only(top: 20, right: 20), // Default padding
    this.content,
  });

  @override
  Widget build(BuildContext context) {
    // Watch the ThemeProvider to rebuild when themeMode changes
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Align(
      alignment: alignment,
      child: Padding(
        padding: padding,
        child: GestureDetector(
          onTap: () {
            themeProvider.toggleTheme(); // Toggle the theme
          },
          child: Container(
            // Mimicking the div with style and onClick
            padding: const EdgeInsets.all(8.0), // Adjust padding as needed
            decoration: BoxDecoration(
              color:
                  isDarkMode
                      ? Colors.grey[800]
                      : Colors.grey[200], // Background color
              borderRadius: BorderRadius.circular(12), // Rounded corners
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min, // Wrap content
              children: [
                Icon(
                  isDarkMode
                      ? Icons.wb_sunny
                      : Icons.nightlight_round, // FiSun / FiMoon
                  color:
                      isDarkMode
                          ? Colors.yellow
                          : Colors.blueGrey, // Icon color
                  size: 24,
                ),
                if (content != null) ...[
                  const SizedBox(width: 8), // Spacing between icon and content
                  content!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
