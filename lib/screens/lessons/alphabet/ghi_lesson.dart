import 'package:flutter/material.dart';
import '../lesson_template.dart';
import '../../../models/lesson_content.dart';

class GHILesson extends StatelessWidget {
  const GHILesson({super.key});

  @override
  Widget build(BuildContext context) {
    final List<LessonContent> data = [
      LessonContent(
        title: "G",
        word: "Goat 🐐",
        videoId: "zRp1141dFFU",
        imagePath: "assets/images/dictionary/g.jpg",
        steps: [
          "Point index and thumb sideways.",
          "Keep other fingers closed.",
          "Angle palm inward."
        ],
      ),
      LessonContent(
        title: "H",
        word: "Hat 🎩",
        videoId: "rlVbEV8say0",
        imagePath: "assets/images/dictionary/h.jpg",
        steps: [
          "Extend index and middle together.",
          "Point them sideways.",
          "Angle palm downward."
        ],
      ),
      LessonContent(
        title: "I",
        word: "Igloo 🧊",
        videoId: "K25uutrP_L0",
        imagePath: "assets/images/dictionary/i.jpg",
        steps: [
          "Extend pinky finger upward.",
          "Close remaining fingers.",
          "Face palm forward."
        ],
      ),
    ];

    return LessonTemplate(
      lessonTitle: "Lesson 3: GHI",
      heroImage: "assets/images/abclesson.png",
      contents: data,
    );
  }
}
