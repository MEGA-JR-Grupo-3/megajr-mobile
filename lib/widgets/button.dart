import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String buttonText;
  final String? buttonLink; // Optional link for navigation
  final bool disabled;
  final VoidCallback? onClick; // Optional click handler

  const CustomButton({
    super.key,
    required this.buttonText,
    this.buttonLink,
    this.disabled = false,
    this.onClick,
  });

  @override
  Widget build(BuildContext context) {
    // Define the gradient colors based on your --primary and --secondary CSS variables
    // You'll need to map these to actual Flutter Color objects.
    // For this example, I'm using placeholder purple and deepPurple.
    const Color primaryColor = Color(0xFF6200EE); // Example primary color
    const Color secondaryColor = Color(0xFF3700B3); // Example secondary color

    final buttonStyle = ElevatedButton.styleFrom(
      padding: EdgeInsets.zero, // Remove default padding to apply gradient to the full area
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(40.0), // Equivalent to rounded-4xl (assuming 40px radius)
      ),
      elevation: 0, // Remove default elevation to prevent shadow interference with gradient
      enableFeedback: !disabled, // Control haptic feedback
      backgroundColor: Colors.transparent, // Make button transparent to show gradient
      shadowColor: Colors.transparent, // Remove shadow
    );

    final buttonContent = Ink(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center, // circle_at_center
          radius: 0.7, // Adjust as needed to get a similar effect to 70% in CSS
          colors: [
            primaryColor, // var(--primary)
            secondaryColor, // var(--secondary)
          ],
        ),
        borderRadius: BorderRadius.circular(40.0),
      ),
      child: InkWell(
        onTap: disabled ? null : onClick ?? () {
          if (buttonLink != null) {
            // Navigate if a link is provided
            Navigator.of(context).pushNamed(buttonLink!);
          }
        },
        borderRadius: BorderRadius.circular(40.0),
        child: Container(
          width: 312.0, // Equivalent to w-[312px]
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0), // Equivalent to p-2, adjust for visual match
          child: Text(
            buttonText,
            style: TextStyle(
              color: Colors.white, // text-[#ffffff]
              fontWeight: FontWeight.w600, // font-[600]
              fontSize: 16.0, // Adjust font size as needed
            ),
          ),
        ),
      ),
    );

    // If disabled, wrap in Opacity for visual effect
    if (disabled) {
      return Opacity(
        opacity: 0.5, // opacity-50
        child: AbsorbPointer( // cursor-not-allowed, prevents taps
          child: ElevatedButton(
            onPressed: () {}, // No-op to satisfy ElevatedButton's non-nullable onPressed
            style: buttonStyle,
            child: buttonContent,
          ),
        ),
      );
    } else {
      return ElevatedButton(
        onPressed: onClick ?? () {
          if (buttonLink != null) {
            Navigator.of(context).pushNamed(buttonLink!);
          }
        },
        style: buttonStyle,
        child: buttonContent,
      );
    }
  }
}