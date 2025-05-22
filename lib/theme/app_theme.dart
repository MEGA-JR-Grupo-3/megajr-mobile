// lib/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:mobile_megajr_grupo3/theme/custom_colors.dart'; // Importe sua extensão de cores

class AppTheme {
  // Tema Claro
  static ThemeData lightTheme = ThemeData(
    // Cores principais que se encaixam no ThemeData padrão do Flutter
    primaryColor: const Color(0xFF491A61), // Cor principal para AppBar, etc.
    scaffoldBackgroundColor: const Color(
      0xFFFFF5EE,
    ), // Cor de fundo padrão da tela
    // Define o brilho do tema para o modo claro
    brightness: Brightness.light,

    // Estilos padrão de AppBar
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF491A61), // Cor de fundo da AppBar
      foregroundColor: Colors.white, // Cor do texto e ícones na AppBar
      elevation: 0, // Sombra da AppBar
    ),

    // Estilos padrão de Texto
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Color(0xFF491A61)), // Equivalente a --text
      bodyMedium: TextStyle(
        color: Color(0xFF313030),
      ), // Equivalente a --subText
      // Adicione outros estilos de texto conforme necessário (headline, title, etc.)
      titleLarge: TextStyle(
        color: Color(0xFF491A61), // Exemplo para títulos maiores
        fontWeight: FontWeight.bold,
      ),
    ),

    // Estilos padrão de Botões (ElevatedButton)
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF392A33), // Equivalente a --button
        foregroundColor: Colors.white, // Cor do texto do botão
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            8,
          ), // Exemplo de borda arredondada
        ),
      ),
    ),

    // Estilos padrão de Card
    cardTheme: const CardThemeData(
      // <-- CORREÇÃO: Use CardThemeData
      color: Color(0xFF2B2B2B), // Equivalente a --bgcard
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
    ),

    // Adicione a extensão de cores personalizadas
    extensions: <ThemeExtension<dynamic>>[
      const CustomAppColors(
        primary: Color(0xFF491A61), // --primary
        secondary: Color(0xFF6C538A), // --secondary
        background: Color(0xFFFFF5EE), // --background
        subBackground: Color(0xFFCECECE), // --subbackground
        bgCard: Color(0xFFEEE3E3), // --bgcard
        text: Color(0xFF491A61), // --text
        subText: Color(0xFF313030), // --subText
        button: Color(0xFF392A33), // --button
      ),
    ],
  );

  // Tema Escuro
  static ThemeData darkTheme = ThemeData(
    // Cores principais que se encaixam no ThemeData padrão do Flutter
    primaryColor: const Color(0xFFAc0000), // Cor principal para AppBar, etc.
    scaffoldBackgroundColor: const Color(
      0xFF1B1B1B,
    ), // Cor de fundo padrão da tela
    // Define o brilho do tema para o modo escuro
    brightness: Brightness.dark,

    // Estilos padrão de AppBar
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFAc0000), // Cor de fundo da AppBar
      foregroundColor: Colors.white, // Cor do texto e ícones na AppBar
      elevation: 0,
    ),

    // Estilos padrão de Texto
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Color(0xFFCE0078)), // Equivalente a --text
      bodyMedium: TextStyle(
        color: Color(0xFF6C6C6C),
      ), // Equivalente a --subText
      titleLarge: TextStyle(
        color: Color(0xFFCE0078), // Exemplo para títulos maiores
        fontWeight: FontWeight.bold,
      ),
    ),

    // Estilos padrão de Botões (ElevatedButton)
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFEBCEDB), // Equivalente a --button
        foregroundColor: Colors.black, // Cor do texto do botão no tema escuro
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),

    // Estilos padrão de Card
    cardTheme: const CardThemeData(
      // <-- CORREÇÃO: Use CardThemeData
      color: Color(0xFF2B2B2B), // Equivalente a --bgcard
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
    ),

    // Adicione a extensão de cores personalizadas
    extensions: <ThemeExtension<dynamic>>[
      const CustomAppColors(
        primary: Color(0xFFAc0000), // --primary
        secondary: Color(0xFFCE0078), // --secondary
        background: Color(0xFF1B1B1B), // --background
        subBackground: Color(0xFF2B2B2B), // --subbackground
        bgCard: Color(0xFF2B2B2B), // --bgcard
        text: Color(0xFFCE0078), // --text
        subText: Color(0xFF6C6C6C), // --subText
        button: Color(0xFFEBCEDB), // --button
      ),
    ],
  );
}
