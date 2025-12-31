import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../lesson_template.dart';
import '../../../models/lesson_content.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

    // DEFINE THE COMPLETION LOGIC
    Future<void> onLessonComplete() async {
      // 1. Save Locally (Works for Guests AND Users)
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(
          'lesson_ghi_done', true); // <--- CHANGE KEY FOR EACH LESSON

      // 2. If Logged In, ALSO Save to Firebase
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        try {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set({
            'lesson_ghi_done': true, // <--- CHANGE KEY FOR EACH LESSON
            'last_active': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        } catch (e) {
          debugPrint("Error saving to cloud: $e");
        }
      }

      if (context.mounted) Navigator.pop(context);
    }

    return LessonTemplate(
      lessonTitle: "Lesson 3: GHI",
      heroImage: "assets/images/ghilesson.png",
      contents: data,
      onComplete: onLessonComplete,
    );
  }
}
