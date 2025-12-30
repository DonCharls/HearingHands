import 'package:flutter/material.dart';
import '../lesson_template.dart';
import '../../../models/lesson_content.dart';

class VWXLesson extends StatelessWidget {
  const VWXLesson({super.key});

  @override
  Widget build(BuildContext context) {
    final List<LessonContent> data = [
      LessonContent(
        title: "V",
        word: "Van 🚐",
        videoId: "Vb2eCb4Uu9Q",
        imagePath: "assets/images/dictionary/v.jpg",
        steps: [
          "Extend index and middle in a V.",
          "Close other fingers.",
          "Face palm forward."
        ],
      ),
      LessonContent(
        title: "W",
        word: "Watch ⌚",
        videoId: "uJqyq6Ss8O0",
        imagePath: "assets/images/dictionary/w.jpg",
        steps: [
          "Extend three fingers upward.",
          "Spread them slightly.",
          "Face palm forward."
        ],
      ),
      LessonContent(
        title: "X",
        word: "Xylophone 🎹",
        videoId: "RIEeMwQxudM",
        imagePath: "assets/images/dictionary/x.jpg",
        steps: [
          "Bend index into a hook.",
          "Keep other fingers closed.",
          "Face palm forward."
        ],
      ),
    ];

    return LessonTemplate(
      lessonTitle: "Lesson 8: VWX",
      heroImage: "assets/images/vwxlesson.png",
      contents: data,
    );
  }
}
