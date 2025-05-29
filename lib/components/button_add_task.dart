import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ButtonAddTask extends StatefulWidget {
  final VoidCallback onPressed;

  const ButtonAddTask({super.key, required this.onPressed});

  @override
  State<ButtonAddTask> createState() => _ButtonAddTaskState();
}

class _ButtonAddTaskState extends State<ButtonAddTask>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 0.5 * 3.14159,
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onPressed,
      child: RotationTransition(
        turns: _rotationAnimation,
        child: Container(
          width: 60.0,
          height: 60.0,
          decoration: const BoxDecoration(shape: BoxShape.circle),
          child: SvgPicture.asset(
            'assets/icons/add_task_icon.svg',
            width: 50.0,
            height: 50.0,
            colorFilter: const ColorFilter.mode(
              Colors.black54,
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }
}
