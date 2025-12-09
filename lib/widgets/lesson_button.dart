import 'package:flutter/material.dart';

class LessonButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color color; // add this

  const LessonButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color = const Color(0xFF58C56E), // default green
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: onPressed,
        child: Text(label,
            style: const TextStyle(fontSize: 16, color: Colors.white)),
      ),
    );
  }
}
