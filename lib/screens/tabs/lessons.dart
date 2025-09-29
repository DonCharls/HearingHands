import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../lessons/a_lessonlist.dart';

class Lessons extends StatelessWidget {
  const Lessons({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF58C56E);
    const cardBackgroundColor = Color.fromARGB(255, 255, 255, 255);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Ready to learn?',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 16),
              _buildLessonCategory(
                context,
                image: 'assets/images/c_a.png',
                title: 'The Alphabet',
                subtitle: 'Learn A-Z signs',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ALessonList()),
                  );
                },
                primaryColor: primaryColor,
                cardColor: cardBackgroundColor,
              ),
              _buildLessonCategory(
                context,
                image: 'assets/images/c_b.png',
                title: 'Greetings & Basics',
                subtitle: 'Start simple conversations',
                onTap: () {},
                primaryColor: primaryColor,
                cardColor: cardBackgroundColor,
              ),
              _buildLessonCategory(
                context,
                image: 'assets/images/c_c.png',
                title: 'Introducing Yourself',
                subtitle: 'Share who you are',
                onTap: () {},
                primaryColor: primaryColor,
                cardColor: cardBackgroundColor,
              ),
              _buildLessonCategory(
                context,
                image: 'assets/images/c_d.png',
                title: 'Numbers & Counting',
                subtitle: 'Learn to count with signs',
                onTap: () {},
                primaryColor: primaryColor,
                cardColor: cardBackgroundColor,
              ),
              _buildLessonCategory(
                context,
                image: 'assets/images/c_e.png',
                title: 'Yes / No & Common Questions',
                subtitle: 'Understand & respond',
                onTap: () {},
                primaryColor: primaryColor,
                cardColor: cardBackgroundColor,
              ),
              _buildLessonCategory(
                context,
                image: 'assets/images/c_f.png',
                title: 'Needs & Feelings',
                subtitle: 'Express how you feel',
                onTap: () {},
                primaryColor: primaryColor,
                cardColor: cardBackgroundColor,
              ),
              _buildLessonCategory(
                context,
                image: 'assets/images/c_g.png',
                title: 'Emergencies',
                subtitle: 'Important signs for help',
                onTap: () {},
                primaryColor: primaryColor,
                cardColor: cardBackgroundColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLessonCategory(
    BuildContext context, {
    String? image,
    IconData? icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color primaryColor,
    required Color cardColor, // added
  }) {
    return Card(
      color: cardColor, // 🟩 Leafy green tint here
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              if (image != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    image,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                )
              else if (icon != null)
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: primaryColor.withAlpha(38),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 30, color: primaryColor),
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
