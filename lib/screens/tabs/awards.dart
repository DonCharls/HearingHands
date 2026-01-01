import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../create_account.dart';
import '../sign_in.dart';

// IMPORT THE NEW DATA FILE
import '../../models/badge_data.dart';

class Awards extends StatefulWidget {
  const Awards({super.key});

  @override
  State<Awards> createState() => _AwardsState();
}

class _AwardsState extends State<Awards> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? "";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // --- GUEST CHECK ---
    if (currentUserId.isEmpty) {
      return _buildGuestView();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          "Achievements Hub", // Updated Title per our discussion
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF58C56E),
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelStyle:
              const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: "My Badges"),
            Tab(text: "Leaderboard"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBadgesTab(),
          _buildLeaderboardTab(),
        ],
      ),
    );
  }

  // --- UPDATED GUEST VIEW (Consistent with Profile) ---
  Widget _buildGuestView() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              Image.asset('assets/images/locked.png', height: 180, width: 180),
              const SizedBox(height: 30),
              const Text(
                "Unlock Your Achievements!",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF58C56E)),
              ),
              const SizedBox(height: 15),
              const Text(
                "Sign in to track your Filipino Sign Language progress and compete on the leaderboard.",
                textAlign: TextAlign.center,
                style:
                    TextStyle(fontSize: 15, color: Colors.black54, height: 1.5),
              ),
              const SizedBox(height: 40),

              // PRIMARY BUTTON: Create Account
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const CreateAccountScreen()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF58C56E),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Text("Create an Account",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                ),
              ),

              const SizedBox(height: 12),

              // SECONDARY BUTTON: Sign In
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SignInScreen()));
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF58C56E), width: 2),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Sign In",
                      style: TextStyle(
                          color: Color(0xFF58C56E),
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- TAB 1: BADGES (Now using allBadges from data file) ---
  Widget _buildBadgesTab() {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        Map<String, dynamic> userData =
            snapshot.data!.data() as Map<String, dynamic>? ?? {};

        // Calculate progress using imported 'allBadges'
        int unlockedCount = 0;
        for (var rule in allBadges) {
          if (rule['check'](userData)) unlockedCount++;
        }
        double progress =
            allBadges.isNotEmpty ? unlockedCount / allBadges.length : 0;

        return Column(
          children: [
            // Progress Header
            Container(
              padding: const EdgeInsets.all(20),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "$unlockedCount / ${allBadges.length} Unlocked",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text("${(progress * 100).toInt()}%",
                          style: const TextStyle(
                              color: Colors.grey, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 10,
                      backgroundColor: Colors.grey.shade200,
                      color: const Color(0xFF58C56E),
                    ),
                  ),
                ],
              ),
            ),

            // Badge Grid
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 0.8,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: allBadges.length, // Uses updated list
                itemBuilder: (context, index) {
                  final badge = allBadges[index];
                  final bool isUnlocked = badge['check'](userData);

                  return GestureDetector(
                    onTap: () => _showBadgeDetails(context, badge, isUnlocked),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 6,
                              offset: const Offset(0, 2))
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Opacity(
                            opacity: isUnlocked ? 1.0 : 0.3,
                            child: Image.asset(badge['image'],
                                height: 50,
                                errorBuilder: (_, __, ___) => const Icon(
                                    Icons.emoji_events,
                                    size: 40,
                                    color: Colors
                                        .grey)), // Handle missing images gracefully
                          ),
                          const SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Text(
                              badge['title'],
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: isUnlocked
                                      ? Colors.black87
                                      : Colors.grey),
                            ),
                          ),
                          if (!isUnlocked)
                            const Padding(
                              padding: EdgeInsets.only(top: 4),
                              child: Icon(Icons.lock,
                                  size: 12, color: Colors.grey),
                            )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  // --- TAB 2: LEADERBOARD ---
  Widget _buildLeaderboardTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .orderBy('signsLearned', descending: true)
          .limit(20)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
              child: Text("Something went wrong loading scores."));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final users = snapshot.data!.docs;

        if (users.isEmpty) {
          return const Center(child: Text("No learners yet. Start a lesson!"));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: users.length,
          itemBuilder: (context, index) {
            final userDoc = users[index].data() as Map<String, dynamic>;
            final String name = userDoc['fullName'] ?? 'Learner';
            final int signs = userDoc['signsLearned'] ?? 0;
            final bool isMe = users[index].id == currentUserId;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: isMe ? const Color(0xFFF0FDF4) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: isMe
                    ? Border.all(color: const Color(0xFF58C56E), width: 1.5)
                    : null,
                boxShadow: [
                  BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.08),
                      spreadRadius: 1,
                      blurRadius: 4)
                ],
              ),
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (index == 0)
                      const Text("🥇", style: TextStyle(fontSize: 22))
                    else if (index == 1)
                      const Text("🥈", style: TextStyle(fontSize: 22))
                    else if (index == 2)
                      const Text("🥉", style: TextStyle(fontSize: 22))
                    else
                      SizedBox(
                          width: 24,
                          child: Text("#${index + 1}",
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey))),
                    const SizedBox(width: 12),
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage: (userDoc['profileImage'] != null)
                          ? AssetImage(userDoc['profileImage'])
                          : const AssetImage(
                              'assets/images/avatar/avatar_1.png'),
                    ),
                  ],
                ),
                title: Text(name,
                    style: TextStyle(
                        fontWeight: isMe ? FontWeight.bold : FontWeight.w500)),
                subtitle: Text("$signs FSL Signs",
                    style: const TextStyle(
                        color: Color(0xFF58C56E), fontWeight: FontWeight.bold)),
                trailing:
                    isMe ? const Icon(Icons.star, color: Colors.orange) : null,
              ),
            );
          },
        );
      },
    );
  }

  // --- POPUP DIALOG ---
  void _showBadgeDetails(
      BuildContext context, Map<String, dynamic> badge, bool isUnlocked) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(badge['image'],
                height: 100,
                color: isUnlocked ? null : Colors.black.withValues(alpha: 0.2),
                colorBlendMode: isUnlocked ? null : BlendMode.srcATop,
                errorBuilder: (_, __, ___) => const Icon(Icons.emoji_events,
                    size: 80, color: Colors.grey)),
            const SizedBox(height: 20),
            Text(badge['title'],
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(badge['desc'],
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.black54)),
            const SizedBox(height: 30),
            if (isUnlocked)
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.check),
                label: const Text("Awesome!"),
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF58C56E),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20))),
              )
            else
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock, color: Colors.grey),
                  SizedBox(width: 8),
                  Text("Keep learning to unlock!",
                      style: TextStyle(
                          color: Colors.grey, fontWeight: FontWeight.bold)),
                ],
              )
          ],
        ),
      ),
    );
  }
}
