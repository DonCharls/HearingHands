import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../lesson_template.dart';
import '../../../models/lesson_content.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DEFLesson extends StatelessWidget {
  const DEFLesson({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. DEFINE YOUR DATA
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

    // 2. DEFINE THE COMPLETION LOGIC
    Future<void> onLessonComplete() async {
      // 1. Save Locally (Works for Guests AND Users)
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(
          'lesson_def_done', true); // <--- CHANGE KEY FOR EACH LESSON

      // 2. If Logged In, ALSO Save to Firebase
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        try {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set({
            'lesson_def_done': true, // <--- CHANGE KEY FOR EACH LESSON
            'last_active': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        } catch (e) {
          debugPrint("Error saving to cloud: $e");
        }
      }

      if (context.mounted) Navigator.pop(context);
    }

    // 3. CALL THE TEMPLATE
    return LessonTemplate(
      lessonTitle: "Lesson 2: DEF",
      heroImage: "assets/images/deflesson.png",
      contents: data,
      onComplete: onLessonComplete, // Pass the logic to the template
    );
  }
}
