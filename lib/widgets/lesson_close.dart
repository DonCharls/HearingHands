import 'package:flutter/material.dart';

class LessonCloseButton extends StatelessWidget {
  final VoidCallback onPressed;

  const LessonCloseButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        width: 48,
        height: 48,
        child: IconButton(
          onPressed: onPressed,
          icon: const Icon(Icons.close, size: 26),
          color: Colors.grey.shade800,
          splashRadius: 24,
          tooltip: 'Exit Lesson',
        ),
      ),
    );
  }
}
