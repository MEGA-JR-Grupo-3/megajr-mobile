// lib/widgets/custom_button.dart
import 'package:flutter/material.dart';

class CustomButton extends StatefulWidget {
  final String buttonText;
  final String? buttonLink;
  final bool disabled;
  final VoidCallback? onClick;
  final Color primaryColor;
  final Color secondaryColor;

  const CustomButton({
    super.key,
    required this.buttonText,
    this.buttonLink,
    this.disabled = false,
    this.onClick,
    this.primaryColor = const Color(0xFF6200EE),
    this.secondaryColor = const Color(0xFFBB86FC),
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final double opacity = widget.disabled ? 0.5 : 1.0;
    final Color textColor = Colors.white;
    final FontWeight fontWeight = FontWeight.w600;
    final double buttonWidth = 312.0;

    final double translateY = _isHovering && !widget.disabled ? -5.0 : 0.0;
    final double elevation = _isHovering && !widget.disabled ? 8.0 : 4.0;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: GestureDetector(
        onTap:
            widget.disabled
                ? null
                : () {
                  if (widget.buttonLink != null) {
                    Navigator.of(context).pushNamed(widget.buttonLink!);
                  }

                  widget.onClick?.call();
                },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          width: buttonWidth,
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40.0),
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 0.8,
              colors: [widget.primaryColor, widget.secondaryColor],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2 * opacity),
                blurRadius: elevation,
                offset: Offset(0, elevation / 2),
              ),
            ],
            color: widget.disabled ? Colors.grey.withValues(alpha: 0.5) : null,
          ),
          transform: Matrix4.translationValues(0.0, translateY, 0.0),
          alignment: Alignment.center,
          child: Opacity(
            opacity: opacity,
            child: Text(
              widget.buttonText,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: fontWeight,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
