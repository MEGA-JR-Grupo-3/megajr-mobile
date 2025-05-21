// lib/components/input_password.dart
import 'package:flutter/material.dart';

class CustomInputPassword extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final ValueChanged<String>? onChanged;

  const CustomInputPassword({
    super.key,
    required this.controller,
    required this.labelText,
    this.hintText = '',
    this.onChanged,
  });

  @override
  State<CustomInputPassword> createState() => _CustomInputPasswordState();
}

class _CustomInputPasswordState extends State<CustomInputPassword> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: _obscureText,
      onChanged: widget.onChanged,
      decoration: InputDecoration(
        labelText: widget.labelText,
        hintText: widget.hintText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
        filled: true,
        fillColor: Colors.grey[200], // Example background color
        suffixIcon: IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility : Icons.visibility_off,
            color: Colors.grey,
          ),
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
        ),
      ),
    );
  }
}
