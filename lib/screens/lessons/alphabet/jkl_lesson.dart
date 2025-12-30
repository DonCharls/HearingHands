import 'package:flutter/material.dart';
import '../lesson_template.dart';
import '../../../models/lesson_content.dart';

class JKLLesson extends StatelessWidget {
  const JKLLesson({super.key});

  @override
  Widget build(BuildContext context) {
    final List<LessonContent> data = [
      LessonContent(
        title: "J",
        word: "Jam 🍓",
        videoId: "xkLWxgdHwHg",
        imagePath: "assets/images/dictionary/j.jpg",
        steps: [
          "Start with letter I handshape.",
          "Draw a J in the air.",
          "End with pinky up."
        ],
      ),
      LessonContent(
        title: "K",
        word: "Kite 🪁",
        videoId: "zBnjL6KbKJQ",
        imagePath: "assets/images/dictionary/k.jpg",
        steps: [
          "Index and middle in a V shape.",
          "Place thumb between them.",
          "Face palm forward."
        ],
      ),
      LessonContent(
        title: "L",
        word: "Lion 🦁",
        videoId: "vbPrLSxMmqU",
        imagePath: "assets/images/dictionary/l.jpg",
        steps: [
          "Extend index upward.",
          "Extend thumb sideways.",
          "Keep other fingers closed."
        ],
      ),
    ];

    return LessonTemplate(
      lessonTitle: "Lesson 4: JKL",
      heroImage: "assets/images/abclesson.png",
      contents: data,
    );
  }
}
