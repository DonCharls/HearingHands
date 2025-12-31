import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../lesson_template.dart';
import '../../../models/lesson_content.dart';
import 'package:shared_preferences/shared_preferences.dart';

class JKLLesson extends StatelessWidget {
  const JKLLesson({super.key});

  @override
  Widget build(BuildContext context) {
    final List<LessonContent> data = [
      LessonContent(
        title: "J",
        word: "Jam 🍓",
        videoId: "xkLWxgdHwHg",
        imagePath: "assets/images/dictionary/j.jpg",
        steps: [
          "Start with letter I handshape.",
          "Draw a J in the air.",
          "End with pinky up."
        ],
      ),
      LessonContent(
        title: "K",
        word: "Kite 🪁",
        videoId: "zBnjL6KbKJQ",
        imagePath: "assets/images/dictionary/k.jpg",
        steps: [
          "Index and middle in a V shape.",
          "Place thumb between them.",
          "Face palm forward."
        ],
      ),
      LessonContent(
        title: "L",
        word: "Lion 🦁",
        videoId: "vbPrLSxMmqU",
        imagePath: "assets/images/dictionary/l.jpg",
        steps: [
          "Extend index upward.",
          "Extend thumb sideways.",
          "Keep other fingers closed."
        ],
      ),
    ];

    // DEFINE THE COMPLETION LOGIC
    Future<void> onLessonComplete() async {
      // 1. Save Locally (Works for Guests AND Users)
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(
          'lesson_jkl_done', true); // <--- CHANGE KEY FOR EACH LESSON

      // 2. If Logged In, ALSO Save to Firebase
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        try {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set({
            'lesson_jkl_done': true, // <--- CHANGE KEY FOR EACH LESSON
            'last_active': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        } catch (e) {
          debugPrint("Error saving to cloud: $e");
        }
      }

      if (context.mounted) Navigator.pop(context);
    }

    return LessonTemplate(
      lessonTitle: "Lesson 4: JKL",
      heroImage: "assets/images/jkllesson.png",
      contents: data,
      onComplete: onLessonComplete,
    );
  }
}
