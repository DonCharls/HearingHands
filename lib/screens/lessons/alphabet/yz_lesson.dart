import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../lesson_template.dart';
import '../../../models/lesson_content.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

    Future<void> onLessonComplete() async {
      // 1. Save Locally (Works for Guests AND Users)
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(
          'lesson_yz_done', true); // <--- CHANGE KEY FOR EACH LESSON

      // 2. If Logged In, ALSO Save to Firebase
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        try {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set({
            'lesson_yz_done': true, // <--- CHANGE KEY FOR EACH LESSON
            'last_active': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        } catch (e) {
          debugPrint("Error saving to cloud: $e");
        }
      }

      if (context.mounted) Navigator.pop(context);
    }

    return LessonTemplate(
      lessonTitle: "Lesson 9: YZ",
      heroImage: "assets/images/yzlesson.png",
      contents: data,
      onComplete: onLessonComplete,
    );
  }
}
