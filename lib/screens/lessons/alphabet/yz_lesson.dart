import 'package:flutter/material.dart';
import '../lesson_template.dart';
import '../../../models/lesson_content.dart';

class YZLesson extends StatelessWidget {
  const YZLesson({super.key});

  @override
  Widget build(BuildContext context) {
    final List<LessonContent> data = [
      LessonContent(
        title: "Y",
        word: "Yo-yo 🪀",
        videoId: "ANTy8GxBDg4",
        imagePath: "assets/images/dictionary/y.jpg",
        steps: [
          "Extend thumb and pinky outward.",
          "Close remaining fingers.",
          "Face palm forward."
        ],
      ),
      LessonContent(
        title: "Z",
        word: "Zebra 🦓",
        videoId: "wM7rrvt2vq8",
        imagePath: "assets/images/dictionary/z.jpg",
        steps: [
          "Extend your index finger.",
          "Draw a Z shape in the air.",
          "Face palm forward."
        ],
      ),
    ];

    return LessonTemplate(
      lessonTitle: "Lesson 9: YZ",
      heroImage: "assets/images/yzlesson.png",
      contents: data,
    );
  }
}
