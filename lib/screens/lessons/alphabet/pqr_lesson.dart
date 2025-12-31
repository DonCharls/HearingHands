import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../lesson_template.dart';
import '../../../models/lesson_content.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PQRLesson extends StatelessWidget {
  const PQRLesson({super.key});

  @override
  Widget build(BuildContext context) {
    final List<LessonContent> data = [
      LessonContent(
        title: "P",
        word: "Pig 🐷",
        videoId: "1CJXJHBsik4",
        imagePath: "assets/images/dictionary/p.jpg",
        steps: [
          "Use the letter K handshape.",
          "Point hand downward.",
          "Face palm downward."
        ],
      ),
      LessonContent(
        title: "Q",
        word: "Queen 👑",
        videoId: "Ida-qsXMTik",
        imagePath: "assets/images/dictionary/q.jpg",
        steps: [
          "Use the letter G handshape.",
          "Point hand downward.",
          "Keep other fingers closed."
        ],
      ),
      LessonContent(
        title: "R",
        word: "Rabbit 🐰",
        videoId: "3IJf2Lu9rpQ",
        imagePath: "assets/images/dictionary/r.jpg",
        steps: [
          "Cross index and middle fingers.",
          "Keep remaining fingers closed.",
          "Face palm forward."
        ],
      ),
    ];

    Future<void> onLessonComplete() async {
      // 1. Save Locally (Works for Guests AND Users)
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(
          'lesson_pqr_done', true); // <--- CHANGE KEY FOR EACH LESSON

      // 2. If Logged In, ALSO Save to Firebase
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        try {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set({
            'lesson_pqr_done': true, // <--- CHANGE KEY FOR EACH LESSON
            'last_active': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        } catch (e) {
          debugPrint("Error saving to cloud: $e");
        }
      }

      if (context.mounted) Navigator.pop(context);
    }

    return LessonTemplate(
      lessonTitle: "Lesson 6: PQR",
      heroImage: "assets/images/pqrlesson.png",
      contents: data,
      onComplete: onLessonComplete,
    );
  }
}
