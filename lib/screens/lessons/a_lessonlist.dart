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
  static const Color backgroundColor = Color(0xFFF5F7FA); // 10/10 Background

  // 1. Data Structure
  final List<Map<String, dynamic>> alphabetLessons = [
    {'group': 'ABC', 'image': 'assets/images/abclesson.png', 'description': 'Learn A, B, and C', 'key': 'lesson_abc_done'},
    {'group': 'DEF', 'image': 'assets/images/deflesson.png', 'description': 'Learn D, E, and F', 'key': 'lesson_def_done'},
    {'group': 'GHI', 'image': 'assets/images/ghilesson.png', 'description': 'Learn G, H, and I', 'key': 'lesson_ghi_done'},
    {'group': 'JKL', 'image': 'assets/images/jkllesson.png', 'description': 'Learn J, K, and L', 'key': 'lesson_jkl_done'},
    {'group': 'MNO', 'image': 'assets/images/mnolesson.png', 'description': 'Learn M, N, and O', 'key': 'lesson_mno_done'},
    {'group': 'PQR', 'image': 'assets/images/pqrlesson.png', 'description': 'Learn P, Q, and R', 'key': 'lesson_pqr_done'},
    {'group': 'STU', 'image': 'assets/images/stulesson.png', 'description': 'Learn S, T, and U', 'key': 'lesson_stu_done'},
    {'group': 'VWX', 'image': 'assets/images/vwxlesson.png', 'description': 'Learn V, W, and X', 'key': 'lesson_vwx_done'},
    {'group': 'YZ',  'image': 'assets/images/yzlesson.png',  'description': 'Learn Y and Z',    'key': 'lesson_yz_done'},
  ];

  Map<String, dynamic> userProgress = {};
  bool isLoading = true;
  int completedCount = 0; // Track progress for header

  @override
  void initState() {
    super.initState();
    _fetchProgress();
  }

  // 2. Fetch completion status & Sync Leaderboard
  Future<void> _fetchProgress() async {
    final user = FirebaseAuth.instance.currentUser;
    final prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> tempProgress = {};
    int count = 0;

    // Load Local Data
    for (var lesson in alphabetLessons) {
      String key = lesson['key'];
      bool localStatus = prefs.getBool(key) ?? false;
      if (localStatus) tempProgress[key] = true;
    }

    // Load & Sync Cloud Data
    if (user != null) {
      try {
        DocumentSnapshot doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (doc.exists) {
          Map<String, dynamic> firestoreData = doc.data() as Map<String, dynamic>;
          tempProgress.addAll(firestoreData);

          // Calculate Total Score for Leaderboard
          for (var lesson in alphabetLessons) {
            if (firestoreData[lesson['key']] == true) {
              count++;
            }
          }
          
          // Self-Healing Score Update
          int totalSigns = count * 3;
          int currentDbScore = firestoreData['signsLearned'] ?? 0;
          
          if (currentDbScore != totalSigns) {
            await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
              'signsLearned': totalSigns
            });
          }
        }
      } catch (e) {
        debugPrint("Error fetching cloud data: $e");
      }
    } else {
      // If guest, just count local
       for (var lesson in alphabetLessons) {
        if (tempProgress[lesson['key']] == true) count++;
       }
    }

    if (mounted) {
      setState(() {
        userProgress = tempProgress;
        completedCount = count;
        isLoading = false;
      });
    }
  }

  bool _isLessonUnlocked(int index) {
    if (index == 0) return true;
    String previousLessonKey = alphabetLessons[index - 1]['key'];
    return userProgress[previousLessonKey] == true;
  }

  // 3. PRO LOGIC: Cleaner Navigation Map
  Widget _getLessonScreen(String group) {
    switch (group) {
      case 'ABC': return const ABCLesson();
      case 'DEF': return const DEFLesson();
      case 'GHI': return const GHILesson();
      case 'JKL': return const JKLLesson();
      case 'MNO': return const MNOLesson();
      case 'PQR': return const PQRLesson();
      case 'STU': return const STULesson();
      case 'VWX': return const VWXLesson();
      case 'YZ':  return const YZLesson();
      default: return const ABCLesson();
    }
  }

  @override
  Widget build(BuildContext context) {
    double progressPercent = completedCount / alphabetLessons.length;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('The Alphabet', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        backgroundColor: primaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryColor))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // --- UPGRADE: PROGRESS HEADER ---
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withValues(alpha: 0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        CircularProgressIndicator(
                          value: progressPercent,
                          backgroundColor: Colors.grey.shade100,
                          color: primaryColor,
                          strokeWidth: 6,
                        ),
                        const SizedBox(width: 20),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Module Progress",
                              style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w600),
                            ),
                            Text(
                              "$completedCount of ${alphabetLessons.length} Completed",
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 25),

                  // --- LIST OF LESSONS ---
                  ListView.builder(
                    shrinkWrap: true, // Needed inside SingleChildScrollView
                    physics: const NeverScrollableScrollPhysics(), // Scroll handled by parent
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
                             ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Complete the previous lesson to unlock!"),
                                backgroundColor: Colors.grey,
                                duration: Duration(milliseconds: 1000),
                              )
                            );
                            return;
                          }

                          // Navigate dynamically
                          await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => _getLessonScreen(lesson['group'])),
                          );

                          _fetchProgress(); // Refresh on return
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }

  // --- 10/10 CARD WIDGET ---
  Widget _buildLessonCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String imagePath,
    required bool unlock,
    required bool isCompleted,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.05),
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
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                // 1. Image with Status Overlay
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      height: 70,
                      width: 70,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: unlock ? Colors.transparent : Colors.grey.shade100,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: ColorFiltered(
                          // Greyscale if locked
                          colorFilter: unlock 
                              ? const ColorFilter.mode(Colors.transparent, BlendMode.multiply)
                              : const ColorFilter.matrix(<double>[
                                  0.2126, 0.7152, 0.0722, 0, 0,
                                  0.2126, 0.7152, 0.0722, 0, 0,
                                  0.2126, 0.7152, 0.0722, 0, 0,
                                  0,      0,      0,      1, 0,
                                ]),
                          child: Image.asset(imagePath, fit: BoxFit.cover),
                        ),
                      ),
                    ),
                    // Lock Icon Overlay
                    if (!unlock)
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.4),
                          shape: BoxShape.circle
                        ),
                        child: const Icon(Icons.lock, color: Colors.white, size: 20),
                      )
                  ],
                ),
                
                const SizedBox(width: 16),
                
                // 2. Text Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: unlock ? Colors.black87 : Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // 3. Status Icon (Right Side)
                if (isCompleted)
                  const Icon(Icons.check_circle, color: primaryColor, size: 28)
                else if (unlock)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle
                    ),
                    child: const Icon(Icons.play_arrow_rounded, color: primaryColor, size: 24),
                  )
                else
                   Icon(Icons.lock_outline, color: Colors.grey.shade300, size: 24),
                   
                const SizedBox(width: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}