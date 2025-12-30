import 'package:flutter/material.dart';
import '../lesson_template.dart';
import '../../../models/lesson_content.dart';

class MNOLesson extends StatelessWidget {
  const MNOLesson({super.key});

  @override
  Widget build(BuildContext context) {
    final List<LessonContent> data = [
      LessonContent(
        title: "M",
        word: "Moon 🌙",
        videoId: "5rmaYRoivgo",
        imagePath: "assets/images/dictionary/m.jpg",
        steps: [
          "Tuck thumb under three fingers.",
          "Keep pinky on outside.",
          "Face palm forward."
        ],
      ),
      LessonContent(
        title: "N",
        word: "Nose 👃",
        videoId: "GxG99do_c9U",
        imagePath: "assets/images/dictionary/n.jpg",
        steps: [
          "Tuck thumb under two fingers.",
          "Keep other fingers relaxed.",
          "Face palm forward."
        ],
      ),
      LessonContent(
        title: "O",
        word: "Owl 🦉",
        videoId: "qAFYchV7IBE",
        imagePath: "assets/images/dictionary/o.jpg",
        steps: [
          "Bring fingertips into a circle.",
          "Keep hand relaxed.",
          "Face palm slightly forward."
        ],
      ),
    ];

    return LessonTemplate(
      lessonTitle: "Lesson 5: MNO",
      heroImage: "assets/images/mnolesson.png",
      contents: data,
    );
  }
}
