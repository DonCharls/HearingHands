import 'package:flutter/material.dart';
import '../lesson_template.dart';
import '../../../models/lesson_content.dart';

class ABCLesson extends StatelessWidget {
  const ABCLesson({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. DEFINE YOUR DATA
    final List<LessonContent> alphabetData = [
      LessonContent(
        title: "A",
        word: "Apple 🍎",
        videoId: "xqmKLCsDqsE",
        imagePath: "assets/images/dictionary/a.jpg",
        steps: [
          "Make a closed fist.",
          "Place thumb on side.",
          "Face palm forward.",
        ],
      ),
      LessonContent(
        title: "B",
        word: "Ball 🏀",
        videoId: "LNwF7eA4Pcg",
        imagePath: "assets/images/dictionary/b.jpg",
        steps: [
          "Extend fingers up.",
          "Place thumb across palm.",
          "Face hand forward.",
        ],
      ),
      LessonContent(
        title: "C",
        word: "Cat 🐱",
        videoId: "9T8ZMxdu_rE",
        imagePath: "assets/images/dictionary/c.jpg",
        steps: [
          "Curve fingers into C shape.",
          "Keep hand relaxed.",
          "Face slightly forward.",
        ],
      ),
    ];

    // 2. CALL THE TEMPLATE
    return LessonTemplate(
      lessonTitle: "Lesson 1: ABC",
      heroImage: "assets/images/abclesson.png",
      contents: alphabetData,
    );
  }
}
