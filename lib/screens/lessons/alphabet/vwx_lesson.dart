import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../lesson_template.dart';
import '../../../models/lesson_content.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

    Future<void> onLessonComplete() async {
      // 1. Save Locally (Works for Guests AND Users)
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(
          'lesson_vwx_done', true); // <--- CHANGE KEY FOR EACH LESSON

      // 2. If Logged In, ALSO Save to Firebase
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        try {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set({
            'lesson_vwx_done': true, // <--- CHANGE KEY FOR EACH LESSON
            'last_active': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        } catch (e) {
          debugPrint("Error saving to cloud: $e");
        }
      }

      if (context.mounted) Navigator.pop(context);
    }

    return LessonTemplate(
      lessonTitle: "Lesson 8: VWX",
      heroImage: "assets/images/vwxlesson.png",
      contents: data,
      onComplete: onLessonComplete,
    );
  }
}
