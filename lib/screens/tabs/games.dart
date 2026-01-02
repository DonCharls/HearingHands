import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../games/sign_sprint.dart';

class Games extends StatelessWidget {
  const Games({super.key});

  final Color primaryColor = const Color(0xFF58C56E);

  @override
  Widget build(BuildContext context) {
    final String uid = FirebaseAuth.instance.currentUser?.uid ?? "";

    return Scaffold(
      // UPGRADE 1: Off-white background makes the white cards POP
      backgroundColor: const Color(0xFFF5F7FA),
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
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- UPGRADE 2: ANCHORED HEADER ---
                  // By putting this in a container or giving it substantial weight,
                  // it stops feeling "floaty".
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withValues(alpha: 0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 5),
                          )
                        ]),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Game Center',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Ready to play?',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                          ],
                        ),
                        Image.asset(
                          'assets/images/talkbearr.png',
                          height: 80, // Slightly bigger mascot
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Section Title
                  const Text(
                    "Available Games",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87),
                  ),
                  const SizedBox(height: 15),

                  // --- 3. GAME CARDS ---

                  // GAME 1: SIGN SPRINT
                  _buildGameCard(
                    context,
                    title: "Sign Sprint",
                    subtitle: "Race against time!",
                    description: "Test your reflex speed.",
                    tag: "⚡ Reflexes", // NEW: Category Tag
                    imagePath: "assets/images/games/signsprint_logo.png",
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

                  // GAME 2: MEMORY MATCH
                  _buildGameCard(
                    context,
                    title: "Memory Match",
                    subtitle: "Find the pairs.",
                    description: "Train your visual memory.",
                    tag: "🧠 Brain", // NEW: Category Tag
                    imagePath: "assets/images/locked.png",
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

  // --- REUSABLE CARD WIDGET (10/10 Version) ---
  Widget _buildGameCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String description,
    required String tag, // NEW PARAMETER
    required String imagePath,
    required String score,
    required Color primaryColor,
    required VoidCallback onTap,
    bool isLocked = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          // Subtle border for definition
          border: Border.all(color: Colors.white, width: 2),
          // Softer, more spread out shadow
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- PORTRAIT IMAGE (3:4) ---
            Container(
              height: 100,
              width: 75,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: isLocked
                          ? Colors.grey.shade300
                          : primaryColor.withValues(alpha: 0.1),
                      width: 1),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5))
                  ]),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.asset(
                  imagePath,
                  color: isLocked ? Colors.grey : null,
                  colorBlendMode: isLocked ? BlendMode.saturation : null,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(width: 20),

            // Text Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // NEW: Category Tag
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                        color: isLocked
                            ? Colors.grey.shade100
                            : primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20)),
                    child: Text(
                      tag,
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isLocked ? Colors.grey : primaryColor),
                    ),
                  ),

                  const SizedBox(height: 8),

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
                        fontSize: 13,
                        color: Colors.black54,
                        fontWeight: FontWeight.w500),
                  ),
                  Text(
                    description,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 12),

                  // Score Row
                  Row(
                    children: [
                      Icon(Icons.emoji_events_rounded,
                          size: 16,
                          color: isLocked ? Colors.grey : Colors.orange),
                      const SizedBox(width: 4),
                      Text(
                        isLocked ? "Locked" : score,
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isLocked ? Colors.grey : Colors.black87),
                      ),
                    ],
                  )
                ],
              ),
            ),

            // Play / Lock Icon (Centered Vertically)
            Padding(
              padding: const EdgeInsets.only(top: 35),
              child: Icon(
                isLocked ? Icons.lock_outline : Icons.play_circle_fill,
                color: isLocked ? Colors.grey.shade300 : primaryColor,
                size: 40, // Bigger, more tappable icon
              ),
            ),
          ],
        ),
      ),
    );
  }
}
