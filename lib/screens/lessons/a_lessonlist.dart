import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Imports for your lessons
import 'alphabet/abc_lesson.dart';
import 'alphabet/def_lesson.dart';
import 'alphabet/ghi_lesson.dart';
import 'alphabet/jkl_lesson.dart';
import 'alphabet/mno_lesson.dart';
import 'alphabet/pqr_lesson.dart';
import 'alphabet/stu_lesson.dart';
import 'alphabet/vwx_lesson.dart';
import 'alphabet/yz_lesson.dart';

class ALessonList extends StatefulWidget {
  const ALessonList({super.key});

  @override
  State<ALessonList> createState() => _ALessonListState();
}

class _ALessonListState extends State<ALessonList> {
  static const Color primaryColor = Color(0xFF58C56E);

  // 1. Data matching your Firebase Keys
  final List<Map<String, dynamic>> alphabetLessons = [
    {
      'group': 'ABC',
      'image': 'assets/images/abclesson.png',
      'description': 'Learn A, B, and C',
      'key': 'lesson_abc_done'
    },
    {
      'group': 'DEF',
      'image': 'assets/images/deflesson.png',
      'description': 'Learn D, E, and F',
      'key': 'lesson_def_done'
    },
    {
      'group': 'GHI',
      'image': 'assets/images/ghilesson.png',
      'description': 'Learn G, H, and I',
      'key': 'lesson_ghi_done'
    },
    {
      'group': 'JKL',
      'image': 'assets/images/jkllesson.png',
      'description': 'Learn J, K, and L',
      'key': 'lesson_jkl_done'
    },
    {
      'group': 'MNO',
      'image': 'assets/images/mnolesson.png',
      'description': 'Learn M, N, and O',
      'key': 'lesson_mno_done'
    },
    {
      'group': 'PQR',
      'image': 'assets/images/pqrlesson.png',
      'description': 'Learn P, Q, and R',
      'key': 'lesson_pqr_done'
    },
    {
      'group': 'STU',
      'image': 'assets/images/stulesson.png',
      'description': 'Learn S, T, and U',
      'key': 'lesson_stu_done'
    },
    {
      'group': 'VWX',
      'image': 'assets/images/vwxlesson.png',
      'description': 'Learn V, W, and X',
      'key': 'lesson_vwx_done'
    },
    {
      'group': 'YZ',
      'image': 'assets/images/yzlesson.png',
      'description': 'Learn Y and Z',
      'key': 'lesson_yz_done'
    },
  ];

  Map<String, dynamic> userProgress = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProgress();
  }

  // 2. Fetch completion status from Firebase & Calculate Score
  Future<void> _fetchProgress() async {
    final user = FirebaseAuth.instance.currentUser;
    Map<String, dynamic> tempProgress = {};

    // 1. ALWAYS load local data first (This covers Guests)
    final prefs = await SharedPreferences.getInstance();

    // Loop through all lessons to see if they are saved locally
    for (var lesson in alphabetLessons) {
      String key = lesson['key'];
      bool localStatus = prefs.getBool(key) ?? false;
      if (localStatus) {
        tempProgress[key] = true;
      }
    }

    // 2. If User is Logged In, MERGE with Firebase data
    if (user != null) {
      try {
        DocumentSnapshot doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (doc.exists) {
          Map<String, dynamic> firestoreData =
              doc.data() as Map<String, dynamic>;

          // Combine local + cloud data
          tempProgress.addAll(firestoreData);

          // --- NEW LOGIC: Calculate Leaderboard Score ---
          int completedLessons = 0;

          // Count how many lessons are actually marked 'true' in Firebase
          for (var lesson in alphabetLessons) {
            if (firestoreData[lesson['key']] == true) {
              completedLessons++;
            }
          }

          // Each lesson = 3 FSL Signs
          int totalSigns = completedLessons * 3;

          // CRITICAL FIX: Check if field is missing OR value is different
          bool fieldMissing = !firestoreData.containsKey('signsLearned');
          int currentDbScore = firestoreData['signsLearned'] ?? 0;

          if (fieldMissing || currentDbScore != totalSigns) {
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .update({'signsLearned': totalSigns});

            debugPrint("Leaderboard Score Fixed: $totalSigns FSL Signs");
          }
          // ---------------------------------------------
        }
      } catch (e) {
        debugPrint("Error fetching cloud data: $e");
      }
    }

    // 3. Update the UI
    if (mounted) {
      setState(() {
        userProgress = tempProgress;
        isLoading = false;
      });
    }
  }

  // 3. Logic: Unlock if it's the first lesson OR previous is done
  bool _isLessonUnlocked(int index) {
    if (index == 0) return true;
    String previousLessonKey = alphabetLessons[index - 1]['key'];
    return userProgress[previousLessonKey] == true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('The Alphabet'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryColor))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: alphabetLessons.length,
              itemBuilder: (context, index) {
                final lesson = alphabetLessons[index];
                final unlocked = _isLessonUnlocked(index);
                final isCompleted = userProgress[lesson['key']] == true;

                return _buildLessonCard(
                  context,
                  title: 'Lesson ${index + 1}: ${lesson['group']}',
                  subtitle: lesson['description'],
                  imagePath: lesson['image'],
                  unlock: unlocked,
                  isCompleted: isCompleted,
                  onTap: () async {
                    if (!unlocked) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content:
                              Text("Complete previous lesson to unlock!")));
                      return;
                    }

                    Widget lessonScreen;
                    switch (lesson['group']) {
                      case 'ABC':
                        lessonScreen = const ABCLesson();
                        break;
                      case 'DEF':
                        lessonScreen = const DEFLesson();
                        break;
                      case 'GHI':
                        lessonScreen = const GHILesson();
                        break;
                      case 'JKL':
                        lessonScreen = const JKLLesson();
                        break;
                      case 'MNO':
                        lessonScreen = const MNOLesson();
                        break;
                      case 'PQR':
                        lessonScreen = const PQRLesson();
                        break;
                      case 'STU':
                        lessonScreen = const STULesson();
                        break;
                      case 'VWX':
                        lessonScreen = const VWXLesson();
                        break;
                      case 'YZ':
                        lessonScreen = const YZLesson();
                        break;
                      default:
                        return;
                    }

                    // --- CRITICAL: Wait for lesson to close, then refresh ---
                    await Navigator.push(context,
                        MaterialPageRoute(builder: (_) => lessonScreen));

                    _fetchProgress();
                  },
                );
              },
            ),
    );
  }

  Widget _buildLessonCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String imagePath,
    required bool unlock,
    required bool isCompleted,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Row(
          children: [
            // Status Indicator Bar
            Container(
              width: 6,
              height: 90,
              decoration: BoxDecoration(
                // Green if done, Grey if locked
                color: isCompleted
                    ? primaryColor
                    : (unlock ? Colors.orangeAccent : Colors.grey.shade300),
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(14),
                    bottomLeft: Radius.circular(14)),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    // Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Stack(
                        children: [
                          Opacity(
                            opacity: unlock ? 1 : 0.4,
                            child: Image.asset(imagePath,
                                width: 70, height: 70, fit: BoxFit.cover),
                          ),
                          if (!unlock)
                            Positioned.fill(
                              child: Container(
                                color: Colors.black26,
                                child: const Icon(Icons.lock,
                                    color: Colors.white, size: 24),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Titles
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title,
                              style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  color:
                                      unlock ? Colors.black : Colors.black38)),
                          const SizedBox(height: 4),
                          Text(subtitle,
                              style: TextStyle(
                                  fontSize: 14,
                                  color: unlock
                                      ? Colors.black54
                                      : Colors.grey.shade400)),
                        ],
                      ),
                    ),
                    // Icons: Checkmark vs Lock
                    if (isCompleted)
                      const Icon(Icons.check_circle,
                          color: primaryColor, size: 24)
                    else
                      Icon(
                          unlock ? Icons.arrow_forward_ios : Icons.lock_outline,
                          size: 18,
                          color:
                              unlock ? Colors.black38 : Colors.grey.shade400),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
