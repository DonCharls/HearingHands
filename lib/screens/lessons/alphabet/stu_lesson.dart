import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../lesson_template.dart';
import '../../../models/lesson_content.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

    Future<void> onLessonComplete() async {
      // 1. Save Locally (Works for Guests AND Users)
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(
          'lesson_stu_done', true); // <--- CHANGE KEY FOR EACH LESSON

      // 2. If Logged In, ALSO Save to Firebase
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        try {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set({
            'lesson_stu_done': true, // <--- CHANGE KEY FOR EACH LESSON
            'last_active': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        } catch (e) {
          debugPrint("Error saving to cloud: $e");
        }
      }

      if (context.mounted) Navigator.pop(context);
    }

    return LessonTemplate(
      lessonTitle: "Lesson 7: STU",
      heroImage: "assets/images/stulesson.png",
      contents: data,
      onComplete: onLessonComplete,
    );
  }
}
