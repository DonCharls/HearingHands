import 'package:flutter/material.dart';
import 'alphabet/abc_lesson.dart';

class ALessonList extends StatelessWidget {
  const ALessonList({super.key});

  static const Color primaryColor = Color(0xFF58C56E);
  static const Color cardColor = Colors.white;

  final List<Map<String, dynamic>> alphabetLessons = const [
    {
      'group': 'ABC',
      'image': 'assets/images/abclesson.png',
      'description': 'Learn how to sign A, B, and C',
    },
    {
      'group': 'DEF',
      'image': 'assets/images/deflesson.png',
      'description': 'Learn how to sign D, E, and F',
    },
    {
      'group': 'GHI',
      'image': 'assets/images/ghilesson.png',
      'description': 'Learn how to sign G, H, and I',
    },
    {
      'group': 'JKL',
      'image': 'assets/images/jkllesson.png',
      'description': 'Learn how to sign J, K, and L',
    },
    {
      'group': 'MNO',
      'image': 'assets/images/mnolesson.png',
      'description': 'Learn how to sign M, N, and O',
    },
    {
      'group': 'PQR',
      'image': 'assets/images/pqrlesson.png',
      'description': 'Learn how to sign P, Q, and R',
    },
    {
      'group': 'STU',
      'image': 'assets/images/stulesson.png',
      'description': 'Learn how to sign S, T, and U',
    },
    {
      'group': 'VWX',
      'image': 'assets/images/vwxlesson.png',
      'description': 'Learn how to sign V, W and X',
    },
    {
      'group': 'YZ',
      'image': 'assets/images/yzlesson.png',
      'description': 'Learn how to sign Y and Z',
    },
  ];

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
          return _buildLessonCard(
            context,
            title: 'Lesson ${index + 1}: ${lesson['group']}',
            subtitle: lesson['description'],
            imagePath: lesson['image'],
            onTap: () {
              if (index == 0) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ABCLesson(),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('This lesson is coming soon!')),
                );
              }
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
    required VoidCallback onTap,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: cardColor,
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  imagePath,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(subtitle,
                        style: const TextStyle(
                            fontSize: 14, color: Colors.black54)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios,
                  size: 16, color: Colors.black38),
            ],
          ),
        ),
      ),
    );
  }
}
