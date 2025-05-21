// lib/components/button.dart
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String buttonText;
  final VoidCallback? onPressed;
  final ButtonStyle? buttonStyle;

  const CustomButton({
    super.key,
    required this.buttonText,
    required this.onPressed,
    this.buttonStyle,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity, // Make the button full width
      child: ElevatedButton(
        onPressed: onPressed,
        style:
            buttonStyle ??
            ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5C2A84), // Default button color
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
        child: Text(
          buttonText,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
