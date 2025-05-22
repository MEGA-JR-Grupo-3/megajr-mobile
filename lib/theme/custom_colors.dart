// lib/theme/custom_colors.dart
import 'package:flutter/material.dart';

class CustomAppColors extends ThemeExtension<CustomAppColors> {
  final Color primary;
  final Color secondary;
  final Color background;
  final Color subBackground;
  final Color bgCard;
  final Color text;
  final Color subText;
  final Color button;

  const CustomAppColors({
    required this.primary,
    required this.secondary,
    required this.background,
    required this.subBackground,
    required this.bgCard,
    required this.text,
    required this.subText,
    required this.button,
  });

  @override
  CustomAppColors copyWith({
    Color? primary,
    Color? secondary,
    Color? background,
    Color? subBackground,
    Color? bgCard,
    Color? text,
    Color? subText,
    Color? button,
  }) {
    return CustomAppColors(
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      background: background ?? this.background,
      subBackground: subBackground ?? this.subBackground,
      bgCard: bgCard ?? this.bgCard,
      text: text ?? this.text,
      subText: subText ?? this.subText,
      button: button ?? this.button,
    );
  }

  @override
  CustomAppColors lerp(ThemeExtension<CustomAppColors>? other, double t) {
    if (other is! CustomAppColors) {
      return this;
    }
    return CustomAppColors(
      primary: Color.lerp(primary, other.primary, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      background: Color.lerp(background, other.background, t)!,
      subBackground: Color.lerp(subBackground, other.subBackground, t)!,
      bgCard: Color.lerp(bgCard, other.bgCard, t)!,
      text: Color.lerp(text, other.text, t)!,
      subText: Color.lerp(subText, other.subText, t)!,
      button: Color.lerp(button, other.button, t)!,
    );
  }

  // Método helper para acessar as cores customizadas
  static CustomAppColors of(BuildContext context) {
    return Theme.of(context).extension<CustomAppColors>()!;
  }
}
