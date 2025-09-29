import 'package:flutter/material.dart';

class LessonCloseButton extends StatelessWidget {
  final VoidCallback onPressed;

  const LessonCloseButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(top: 5.0, left: 1.0),
        child: IconButton(
          onPressed: onPressed,
          icon: const Icon(Icons.close),
          color: Colors.black87,
          iconSize: 26,
          tooltip: 'Exit Lesson',
          splashRadius: 22,
        ),
      ),
    );
  }
}
