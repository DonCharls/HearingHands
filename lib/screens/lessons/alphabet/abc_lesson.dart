import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../lesson_template.dart';
import '../../../models/lesson_content.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

    // 2. DEFINE THE COMPLETION LOGIC
    Future<void> onLessonComplete() async {
      // 1. Save Locally (Works for Guests AND Users)
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(
          'lesson_abc_done', true); // <--- CHANGE KEY FOR EACH LESSON

      // 2. If Logged In, ALSO Save to Firebase
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        try {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set({
            'lesson_abc_done': true, // <--- CHANGE KEY FOR EACH LESSON
            'last_active': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        } catch (e) {
          debugPrint("Error saving to cloud: $e");
        }
      }

      if (context.mounted) Navigator.pop(context);
    }

    // 3. CALL THE TEMPLATE WITH THE LOGIC
    return LessonTemplate(
      lessonTitle: "Lesson 1: ABC",
      heroImage: "assets/images/abclesson.png",
      contents: alphabetData,
      onComplete: onLessonComplete, // <--- Pass the function here
    );
  }
}
