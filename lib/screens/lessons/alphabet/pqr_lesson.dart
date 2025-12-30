import 'package:flutter/material.dart';
import '../lesson_template.dart';
import '../../../models/lesson_content.dart';

class PQRLesson extends StatelessWidget {
  const PQRLesson({super.key});

  @override
  Widget build(BuildContext context) {
    final List<LessonContent> data = [
      LessonContent(
        title: "P",
        word: "Pig 🐷",
        videoId: "1CJXJHBsik4",
        imagePath: "assets/images/dictionary/p.jpg",
        steps: [
          "Use the letter K handshape.",
          "Point hand downward.",
          "Face palm downward."
        ],
      ),
      LessonContent(
        title: "Q",
        word: "Queen 👑",
        videoId: "Ida-qsXMTik",
        imagePath: "assets/images/dictionary/q.jpg",
        steps: [
          "Use the letter G handshape.",
          "Point hand downward.",
          "Keep other fingers closed."
        ],
      ),
      LessonContent(
        title: "R",
        word: "Rabbit 🐰",
        videoId: "3IJf2Lu9rpQ",
        imagePath: "assets/images/dictionary/r.jpg",
        steps: [
          "Cross index and middle fingers.",
          "Keep remaining fingers closed.",
          "Face palm forward."
        ],
      ),
    ];

    return LessonTemplate(
      lessonTitle: "Lesson 6: PQR",
      heroImage: "assets/images/abclesson.png",
      contents: data,
    );
  }
}
