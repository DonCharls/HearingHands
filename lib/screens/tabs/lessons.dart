import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../lessons/a_lessonlist.dart';

class Lessons extends StatefulWidget {
  const Lessons({super.key});

  @override
  State<Lessons> createState() => _LessonsState();
}

class _LessonsState extends State<Lessons> {
  // Brand Colors
  final Color primaryColor = const Color(0xFF58C56E);
  final Color backgroundColor = const Color(0xFFF5F7FA);

  // --- STATE VARIABLES ---
  double alphabetProgress = 0.0; // 0.0 to 1.0
  int streak = 0; // Future: Sync this with Firebase too

  @override
  void initState() {
    super.initState();
    _calculateProgress();
  }

  // --- THE CALCULATOR LOGIC ---
  Future<void> _calculateProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final user = FirebaseAuth.instance.currentUser;

    // 1. Define the keys for the Alphabet Module
    List<String> alphabetKeys = [
      'lesson_abc_done',
      'lesson_def_done',
      'lesson_ghi_done',
      'lesson_jkl_done',
      'lesson_mno_done',
      'lesson_pqr_done',
      'lesson_stu_done',
      'lesson_vwx_done',
      'lesson_yz_done'
    ];

    int completedCount = 0;

    // 2. Check Local Data (Fastest)
    Map<String, bool> statusMap = {};
    for (String key in alphabetKeys) {
      if (prefs.getBool(key) == true) {
        statusMap[key] = true;
      }
    }

    // 3. Sync with Cloud (Most Accurate)
    if (user != null) {
      try {
        DocumentSnapshot doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (doc.exists) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          // Merge cloud data into our map
          for (String key in alphabetKeys) {
            if (data[key] == true) statusMap[key] = true;
          }
        }
      } catch (e) {
        debugPrint("Error syncing progress: $e");
      }
    }

    // 4. Count the "True" values
    completedCount = statusMap.length;

    // 5. Update the UI
    if (mounted) {
      setState(() {
        // Example: 3 completed / 9 total = 0.33
        alphabetProgress = completedCount / alphabetKeys.length;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- 1. HERO HEADER ---
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Welcome back!",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Ready to learn?",
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                      Image.asset(
                        'assets/images/readingbear.png',
                        height: 90,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                const Text(
                  "Your Lessons",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),

                // --- 2. LESSON LIST ---

                // Lesson 1: The Alphabet (NOW CONNECTED)
                _buildLessonCard(
                  context,
                  image: 'assets/images/c_a.png',
                  title: 'The Alphabet',
                  subtitle: 'Foundations A-Z',
                  progress: alphabetProgress, // <--- UPDATING VARIABLE
                  primaryColor: primaryColor,
                  onTap: () async {
                    // Wait for the user to return from the lesson list
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ALessonList()),
                    );
                    // When they come back, re-calculate the progress!
                    _calculateProgress();
                  },
                ),

                // Lesson 2: Greetings
                _buildLessonCard(
                  context,
                  image: 'assets/images/c_b.png',
                  title: 'Greetings & Basics',
                  subtitle: 'Hello, Thank you...',
                  progress: 0.0, // Future: Create keys for this module
                  primaryColor: Colors.blueAccent,
                  onTap: () {},
                ),

                // Lesson 3: Introducing Yourself
                _buildLessonCard(
                  context,
                  image: 'assets/images/c_c.png',
                  title: 'Introducing Yourself',
                  subtitle: 'My name is...',
                  progress: 0.0,
                  primaryColor: Colors.orange,
                  onTap: () {},
                ),

                // Lesson 4: Numbers
                _buildLessonCard(
                  context,
                  image: 'assets/images/c_d.png',
                  title: 'Numbers & Counting',
                  subtitle: '1, 2, 3, 10...',
                  progress: 0.0,
                  primaryColor: Colors.amber,
                  onTap: () {},
                ),

                // Lesson 5: Questions
                _buildLessonCard(
                  context,
                  image: 'assets/images/c_e.png',
                  title: 'Yes/No & Questions',
                  subtitle: 'Who, What, Where...',
                  progress: 0.0,
                  primaryColor: Colors.purpleAccent,
                  onTap: () {},
                ),

                // Lesson 6: Feelings
                _buildLessonCard(
                  context,
                  image: 'assets/images/c_f.png',
                  title: 'Needs & Feelings',
                  subtitle: 'Happy, Sad, Hungry...',
                  progress: 0.0,
                  primaryColor: Colors.pinkAccent,
                  onTap: () {},
                ),

                // Lesson 7: Emergencies
                _buildLessonCard(
                  context,
                  image: 'assets/images/c_g.png',
                  title: 'Emergencies',
                  subtitle: 'Help, Hurt, Doctor...',
                  progress: 0.0,
                  primaryColor: Colors.redAccent,
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- REUSABLE CARD (No Changes Needed Here) ---
  Widget _buildLessonCard(
    BuildContext context, {
    required String image,
    required String title,
    required String subtitle,
    required double progress,
    required VoidCallback onTap,
    required Color primaryColor,
  }) {
    bool isStarted = progress > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(image, fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: progress,
                                backgroundColor: Colors.grey.shade100,
                                color: primaryColor,
                                minHeight: 6,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "${(progress * 100).toInt()}%",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isStarted
                                  ? primaryColor
                                  : Colors.grey.shade400,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.play_arrow_rounded,
                    color: primaryColor,
                    size: 20,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
