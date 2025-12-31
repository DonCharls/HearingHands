import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../lesson_template.dart';
import '../../../models/lesson_content.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

    Future<void> onLessonComplete() async {
      // 1. Save Locally (Works for Guests AND Users)
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(
          'lesson_mno_done', true); // <--- CHANGE KEY FOR EACH LESSON

      // 2. If Logged In, ALSO Save to Firebase
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        try {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set({
            'lesson_mno_done': true, // <--- CHANGE KEY FOR EACH LESSON
            'last_active': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        } catch (e) {
          debugPrint("Error saving to cloud: $e");
        }
      }

      if (context.mounted) Navigator.pop(context);
    }

    return LessonTemplate(
      lessonTitle: "Lesson 5: MNO",
      heroImage: "assets/images/mnolesson.png",
      contents: data,
      onComplete: onLessonComplete,
    );
  }
}
