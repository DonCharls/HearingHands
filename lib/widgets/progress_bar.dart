import 'package:flutter/material.dart';

class ProgressBar extends StatelessWidget {
  final double progress;
  final double height;
  final Color backgroundColor;
  final Color fillColor;

  const ProgressBar({
    super.key,
    required this.progress,
    this.height = 6.0,
    this.backgroundColor = const Color(0xFFE0E0E0),
    this.fillColor = const Color(0xFF58C56E),
  });

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.of(context).size.width - 96;

    return ClipRRect(
      borderRadius: BorderRadius.circular(height / 2),
      child: Container(
        height: height,
        color: backgroundColor,
        child: Align(
          alignment: Alignment.centerLeft,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: maxWidth * progress.clamp(0.0, 1.0),
            color: fillColor,
          ),
        ),
      ),
    );
  }
}
