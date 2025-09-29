import 'package:flutter/material.dart';

class LessonBackButton extends StatelessWidget {
  final VoidCallback onPressed;

  const LessonBackButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48, // Match the close button’s tap target
      height: 48,
      child: IconButton(
        icon: const Icon(Icons.arrow_back_ios, size: 20),
        onPressed: onPressed,
        color: Colors.grey[800],
        splashRadius: 24,
        tooltip: 'Back',
      ),
    );
  }
}
