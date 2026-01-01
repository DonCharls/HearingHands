import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../games/sign_sprint.dart'; // Import your game file

class Games extends StatelessWidget {
  const Games({super.key});

  // Using your app's primary green
  final Color primaryColor = const Color(0xFF58C56E);

  @override
  Widget build(BuildContext context) {
    final String uid = FirebaseAuth.instance.currentUser?.uid ?? "";

    return Scaffold(
      backgroundColor: Colors.white, // Clean white background like lessons
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .snapshots(),
          builder: (context, snapshot) {
            int highScore = 0;
            if (snapshot.hasData && snapshot.data!.exists) {
              final data = snapshot.data!.data() as Map<String, dynamic>?;
              highScore = data?['gameHighScore'] ?? 0;
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- 1. HEADER SECTION (Consistent with Lessons) ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            'Ready to play?',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: primaryColor, // Consistent Color
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // --- 2. GAME CARDS ---

                  // GAME 1: SIGN SPRINT (Live)
                  _buildGameCard(
                    context,
                    title: "Sign Sprint",
                    subtitle: "Race against the clock to match signs!",
                    imagePath:
                        "assets/images/awards/quicklearner.png", // Use an existing asset as icon
                    score: "$highScore pts",
                    primaryColor: primaryColor,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SignSprintGame()),
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  // GAME 2: COMING SOON (Locked)
                  _buildGameCard(
                    context,
                    title: "Memory Match",
                    subtitle: "Find the matching pairs of signs.",
                    imagePath:
                        "assets/images/locked.png", // Use your locked asset
                    score: "Locked",
                    primaryColor: Colors.grey,
                    isLocked: true,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text("Coming soon! Master your lessons first."),
                          backgroundColor: Colors.grey,
                          duration: Duration(milliseconds: 800),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // --- REUSABLE CARD WIDGET ---
  Widget _buildGameCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String imagePath,
    required String score,
    required Color primaryColor,
    required VoidCallback onTap,
    bool isLocked = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: isLocked
                  ? Colors.grey.shade200
                  : primaryColor.withOpacity(0.3),
              width: 2),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(isLocked ? 0.0 : 0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon / Image
            Container(
              height: 60,
              width: 60,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isLocked
                    ? Colors.grey.shade100
                    : primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Image.asset(imagePath,
                  color: isLocked ? Colors.grey : null, // Grayscale if locked
                  fit: BoxFit.contain),
            ),

            const SizedBox(width: 20),

            // Text Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isLocked ? Colors.grey : Colors.black87),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey.shade600, height: 1.2),
                  ),
                  const SizedBox(height: 8),

                  // Score Tag
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isLocked
                          ? Colors.grey.shade200
                          : primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isLocked ? "Coming Soon" : "High Score: $score",
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isLocked ? Colors.grey : primaryColor),
                    ),
                  )
                ],
              ),
            ),

            // Play / Lock Icon
            Icon(
              isLocked ? Icons.lock_outline : Icons.play_circle_fill,
              color: isLocked ? Colors.grey.shade300 : primaryColor,
              size: 32,
            ),
          ],
        ),
      ),
    );
  }
}
