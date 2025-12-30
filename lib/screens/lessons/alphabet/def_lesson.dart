import 'package:flutter/material.dart';
import '../lesson_template.dart';
import '../../../models/lesson_content.dart';

class DEFLesson extends StatelessWidget {
  const DEFLesson({super.key});

  @override
  Widget build(BuildContext context) {
    final List<LessonContent> data = [
      LessonContent(
        title: "D",
        word: "Dog 🐶",
        videoId: "tjH-9HmLdpE",
        imagePath: "assets/images/dictionary/d.jpg",
        steps: [
          "Raise index finger up.",
          "Touch thumb to other fingers.",
          "Face palm forward."
        ],
      ),
      LessonContent(
        title: "E",
        word: "Egg 🥚",
        videoId: "gZcqtqNWmlQ",
        imagePath: "assets/images/dictionary/e.jpg",
        steps: [
          "Curl fingers toward thumb.",
          "Bring fingertips close.",
          "Face palm slightly forward."
        ],
      ),
      LessonContent(
        title: "F",
        word: "Fish 🐟",
        videoId: "DNVezgdTbcM",
        imagePath: "assets/images/dictionary/f.jpg",
        steps: [
          "Thumb and index form circle.",
          "Extend other fingers up.",
          "Face palm forward."
        ],
      ),
    ];

    return LessonTemplate(
      lessonTitle: "Lesson 2: DEF",
      heroImage: "assets/images/deflesson.png",
      contents: data,
    );
  }
}
