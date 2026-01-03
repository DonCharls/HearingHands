import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Game Imports
import '../games/sign_sprint.dart';
import '../games/memory_match.dart';

// Auth Import (For the Guest Nudge)
import '../create_account.dart';

class Games extends StatelessWidget {
  const Games({super.key});

  final Color primaryColor = const Color(0xFF58C56E);

  @override
  Widget build(BuildContext context) {
    // 1. SAFELY CHECK FOR USER
    final User? user = FirebaseAuth.instance.currentUser;
    final String? uid = user?.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        // 2. SWITCH BASED ON LOGIN STATUS
        child: uid == null
            ? _buildGuestContent(context) // Show this if no account
            : _buildUserContent(context, uid), // Show this if logged in
      ),
    );
  }

  // --- LAYOUT FOR LOGGED IN USERS ---
  Widget _buildUserContent(BuildContext context, String uid) {
    return StreamBuilder<DocumentSnapshot>(
      stream:
          FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
      builder: (context, snapshot) {
        int sprintScore = 0;
        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>?;
          sprintScore = data?['gameHighScore'] ?? 0;
        }
        // Pass the score and "false" for isGuest
        return _buildMainLayout(context, sprintScore, isGuest: false);
      },
    );
  }

  // --- LAYOUT FOR GUESTS ---
  Widget _buildGuestContent(BuildContext context) {
    // Pass 0 score and "true" for isGuest
    return _buildMainLayout(context, 0, isGuest: true);
  }

  // --- SHARED MAIN LAYOUT ---
  Widget _buildMainLayout(BuildContext context, int sprintScore,
      {required bool isGuest}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- HERO HEADER ---
          _buildHeader(isGuest),

          const SizedBox(height: 30),

          // --- GUEST NUDGE (Clickable!) ---
          if (isGuest) _buildGuestNudge(context),

          // --- SECTION 1: AVAILABLE GAMES ---
          const Text(
            "Available Games",
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87),
          ),
          const SizedBox(height: 15),

          // 1. SIGN SPRINT
          _buildGameCard(
            context,
            title: "Sign Sprint",
            subtitle: "Race against time!",
            description: "Test your reflex speed.",
            tag: "⚡ Reflexes",
            imagePath: "assets/images/games/signsprint_logo.png",
            // UX: Show "Guest Mode" instead of "0 pts"
            score: isGuest ? "Guest Mode" : "$sprintScore pts",
            primaryColor: primaryColor,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SignSprintGame()),
              );
            },
          ),

          const SizedBox(height: 20),

          // 2. MEMORY MATCH
          _buildGameCard(
            context,
            title: "Memory Match",
            subtitle: "Find the pairs.",
            description: "Train your visual memory.",
            tag: "🧠 Brain",
            imagePath: "assets/images/games/memorymatch_logo.png",
            score: "Play Now",
            primaryColor: Colors.teal,
            isLocked: false,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const MemoryMatchGame()),
              );
            },
          ),

          const SizedBox(height: 35),

          // --- SECTION 2: COMING SOON ---
          // FIXED: Added 'const' to the Row to fix the error
          const Row(
            children: [
              Icon(Icons.rocket_launch_rounded, size: 20, color: Colors.orange),
              SizedBox(width: 8),
              Text(
                "Coming Soon",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 15),

          // 3. EMERGENCY HERO (Red)
          _buildGameCard(
            context,
            title: "Emergency Hero",
            subtitle: "Act fast in a crisis!",
            description: "Learn vital safety signs.",
            tag: "🆘 Safety",
            imagePath: "assets/images/games/emergencyhero_logo.png",
            score: "Coming Soon",
            primaryColor: Colors.redAccent,
            isLocked: true,
            onTap: () => _showComingSoon(context),
          ),

          const SizedBox(height: 20),

          // 4. SIGN-A-SENTENCE (Blue)
          _buildGameCard(
            context,
            title: "Sign-A-Sentence",
            subtitle: "Build the conversation.",
            description: "Practice grammar & syntax.",
            tag: "💬 Chat",
            imagePath: "assets/images/games/sentence_logo.png",
            score: "Coming Soon",
            primaryColor: Colors.blueAccent,
            isLocked: true,
            onTap: () => _showComingSoon(context),
          ),

          const SizedBox(height: 20),

          // 5. NUMBER POPPER (Orange)
          _buildGameCard(
            context,
            title: "Number Popper",
            subtitle: "Catch the digits!",
            description: "Master counting 1-10.",
            tag: "🔢 Math",
            imagePath: "assets/images/games/numbers_logo.png",
            score: "Coming Soon",
            primaryColor: Colors.amber,
            isLocked: true,
            onTap: () => _showComingSoon(context),
          ),

          const SizedBox(height: 20),

          // 6. MOOD MASTER (Purple)
          _buildGameCard(
            context,
            title: "Mood Master",
            subtitle: "Match the emotion.",
            description: "Express needs & feelings.",
            tag: "😊 Emotions",
            imagePath: "assets/images/games/mood_logo.png",
            score: "Coming Soon",
            primaryColor: Colors.purpleAccent,
            isLocked: true,
            onTap: () => _showComingSoon(context),
          ),
        ],
      ),
    );
  }

  // --- HELPER WIDGETS ---

  Widget _buildHeader(bool isGuest) {
    return Container(
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
              Text(
                isGuest ? 'Guest Mode' : 'Game Center', // Dynamic text
                style: const TextStyle(
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
            'assets/images/gamerbear.png',
            height: 80,
          ),
        ],
      ),
    );
  }

  // --- GUEST NUDGE (UPDATED: CLICKABLE) ---
  Widget _buildGuestNudge(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to the Create Account screen
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CreateAccountScreen()),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 25),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [primaryColor, primaryColor.withValues(alpha: 0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person_add_rounded,
                  color: Colors.white, size: 24),
            ),
            const SizedBox(width: 15),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Don't lose your high scores!",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 2),
                  Text(
                    "Tap here to create an account.",
                    style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                color: Colors.white70, size: 16),
          ],
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Coming soon! We are crafting this game for you."),
        backgroundColor: Colors.grey,
        duration: Duration(milliseconds: 1000),
      ),
    );
  }

  Widget _buildGameCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String description,
    required String tag,
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
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: isLocked
                  ? Colors.grey.withValues(alpha: 0.1)
                  : primaryColor.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 100,
              width: 75,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: primaryColor.withValues(alpha: 0.2), width: 1),
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
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => Container(
                    color: primaryColor.withValues(alpha: 0.1),
                    child: Icon(Icons.image, color: primaryColor),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20)),
                    child: Text(
                      tag,
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: primaryColor),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isLocked ? Colors.black54 : Colors.black87),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
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
                  Row(
                    children: [
                      Icon(
                        isLocked
                            ? Icons.hourglass_empty_rounded
                            : Icons.emoji_events_rounded,
                        size: 16,
                        color: isLocked ? Colors.grey : Colors.orange,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        score,
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
            Padding(
              padding: const EdgeInsets.only(top: 35),
              child: Icon(
                isLocked ? Icons.lock_rounded : Icons.play_circle_fill,
                color: isLocked ? Colors.grey.shade300 : primaryColor,
                size: 40,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
