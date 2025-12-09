import 'package:flutter/material.dart';
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

  final List<Map<String, dynamic>> alphabetLessons = [
    {
      'group': 'ABC',
      'image': 'assets/images/abclesson.png',
      'description': 'Learn how to sign A, B, and C',
      'key': 'lesson_abc_done'
    },
    {
      'group': 'DEF',
      'image': 'assets/images/deflesson.png',
      'description': 'Learn how to sign D, E, and F',
      'key': 'lesson_def_done'
    },
    {
      'group': 'GHI',
      'image': 'assets/images/ghilesson.png',
      'description': 'Learn how to sign G, H, and I',
      'key': 'lesson_ghi_done'
    },
    {
      'group': 'JKL',
      'image': 'assets/images/jkllesson.png',
      'description': 'Learn how to sign J, K, and L',
      'key': 'lesson_jkl_done'
    },
    {
      'group': 'MNO',
      'image': 'assets/images/mnolesson.png',
      'description': 'Learn how to sign M, N, and O',
      'key': 'lesson_mno_done'
    },
    {
      'group': 'PQR',
      'image': 'assets/images/pqrlesson.png',
      'description': 'Learn how to sign P, Q, and R',
      'key': 'lesson_pqr_done'
    },
    {
      'group': 'STU',
      'image': 'assets/images/stulesson.png',
      'description': 'Learn how to sign S, T, and U',
      'key': 'lesson_stu_done'
    },
    {
      'group': 'VWX',
      'image': 'assets/images/vwxlesson.png',
      'description': 'Learn how to sign V, W and X',
      'key': 'lesson_vwx_done'
    },
    {
      'group': 'YZ',
      'image': 'assets/images/yzlesson.png',
      'description': 'Learn how to sign Y and Z',
      'key': 'lesson_yz_done'
    },
  ];

  Map<String, bool> lessonStatus = {};

  @override
  void initState() {
    super.initState();
    _loadLessonStatus();
  }

  Future<void> _loadLessonStatus() async {
    Map<String, bool> status = {};

    // Unlock all lessons
    for (var lesson in alphabetLessons) {
      status[lesson['key']] = true;
    }

    setState(() => lessonStatus = status);
  }

  bool _isLessonUnlocked(int index) {
    // All lessons are unlocked
    return true;
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
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: alphabetLessons.length,
        itemBuilder: (context, index) {
          final lesson = alphabetLessons[index];
          final unlocked = _isLessonUnlocked(index);

          return _buildLessonCard(
            context,
            title: 'Lesson ${index + 1}: ${lesson['group']}',
            subtitle: lesson['description'],
            imagePath: lesson['image'],
            unlock: unlocked,
            onTap: () {
              if (!unlocked) return;

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
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Lesson coming soon!')));
                  return;
              }

              Navigator.push(
                  context, MaterialPageRoute(builder: (_) => lessonScreen));
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
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: unlock ? onTap : null,
        borderRadius: BorderRadius.circular(14),
        child: Row(
          children: [
            Container(
              width: 6,
              height: 90,
              decoration: BoxDecoration(
                color: unlock ? primaryColor : Colors.grey.shade300,
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
                    Icon(unlock ? Icons.arrow_forward_ios : Icons.lock_outline,
                        size: 18,
                        color: unlock ? Colors.black38 : Colors.grey.shade400),
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
