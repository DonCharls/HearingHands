import 'package:flutter/material.dart';
import '../lesson_template.dart';
import '../../../models/lesson_content.dart';

class STULesson extends StatelessWidget {
  const STULesson({super.key});

  @override
  Widget build(BuildContext context) {
    final List<LessonContent> data = [
      LessonContent(
        title: "S",
        word: "Sun ☀️",
        videoId: "OKbAFVxD0uE",
        imagePath: "assets/images/dictionary/s.jpg",
        steps: [
          "Make a fist.",
          "Place thumb in front of fingers.",
          "Face palm forward."
        ],
      ),
      LessonContent(
        title: "T",
        word: "Tree 🌳",
        videoId: "wcZT34vawKU",
        imagePath: "assets/images/dictionary/t.jpg",
        steps: [
          "Make a fist.",
          "Place thumb between index and middle.",
          "Face palm forward."
        ],
      ),
      LessonContent(
        title: "U",
        word: "Umbrella ☂️",
        videoId: "dy4e5KvFzqQ",
        imagePath: "assets/images/dictionary/u.jpg",
        steps: [
          "Extend index and middle together.",
          "Point them upward.",
          "Face palm forward."
        ],
      ),
    ];

    return LessonTemplate(
      lessonTitle: "Lesson 7: STU",
      heroImage: "assets/images/abclesson.png",
      contents: data,
    );
  }
}
