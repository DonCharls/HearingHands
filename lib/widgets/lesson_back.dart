import 'package:flutter/material.dart';

class LessonBackButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isDisabled;

  const LessonBackButton(
      {super.key, required this.onPressed, this.isDisabled = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 48,
      child: IconButton(
        icon: Icon(
          Icons.arrow_back_ios,
          size: 24,
          color: isDisabled ? Colors.grey.shade400 : Colors.grey.shade800,
        ),
        onPressed: isDisabled ? null : onPressed,
        splashRadius: 24,
        tooltip: 'Back',
      ),
    );
  }
}
