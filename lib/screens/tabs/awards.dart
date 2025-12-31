import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Awards extends StatefulWidget {
  const Awards({super.key});

  @override
  State<Awards> createState() => _AwardsState();
}

class _AwardsState extends State<Awards> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? "";

  // 1. Badge Logic - Checks your Firestore data to unlock badges
  final List<Map<String, dynamic>> badgeRules = [
    {
      "title": "Trailblazer",
      "desc": "Log in for the first time.",
      "image": "assets/images/awards/trailblazer.png",
      "check": (data) => true, // Always true if they are logged in
    },
    {
      "title": "Quick Learner",
      "desc": "Complete your first lesson.",
      "image": "assets/images/awards/quicklearner.png",
      "check": (data) => data['lesson_abc_done'] == true,
    },
    {
      "title": "Triple Threat",
      "desc": "Finish 3 lessons (ABC, DEF, GHI).",
      "image": "assets/images/awards/triplethreat.png",
      "check": (data) =>
          data['lesson_abc_done'] == true &&
          data['lesson_def_done'] == true &&
          data['lesson_ghi_done'] == true,
    },
    {
      "title": "Alphabet Ace",
      "desc": "Complete the entire Alphabet.",
      "image": "assets/images/awards/alphabetace.png",
      "check": (data) => data['lesson_yz_done'] == true,
    },
    // Add more badge rules here as you build more features!
  ];

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
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("Achievements Hub"),
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

  // --- TAB 1: BADGES ---
  Widget _buildBadgesTab() {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());

        Map<String, dynamic> userData =
            snapshot.data!.data() as Map<String, dynamic>? ?? {};

        // Calculate progress
        int unlockedCount = 0;
        for (var rule in badgeRules) {
          if (rule['check'](userData)) unlockedCount++;
        }
        double progress =
            badgeRules.isNotEmpty ? unlockedCount / badgeRules.length : 0;

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
                        "$unlockedCount / ${badgeRules.length} Unlocked",
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
                itemCount: badgeRules.length,
                itemBuilder: (context, index) {
                  final badge = badgeRules[index];
                  final bool isUnlocked = badge['check'](userData);

                  return GestureDetector(
                    onTap: () => _showBadgeDetails(context, badge, isUnlocked),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.05),
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
                                    color: Colors.orange)),
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

  // --- TAB 2: LEADERBOARD (Updated to use 'signsLearned') ---
  Widget _buildLeaderboardTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .orderBy('signsLearned',
              descending: true) // <--- Sorting by FSL Signs
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
            final int signs =
                userDoc['signsLearned'] ?? 0; // Get the calculated score
            final String? photoUrl = userDoc['profileImage'];
            final bool isMe = users[index].id == currentUserId;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: isMe
                    ? const Color(0xFFF0FDF4)
                    : Colors.white, // Light green for current user
                borderRadius: BorderRadius.circular(12),
                border: isMe
                    ? Border.all(color: const Color(0xFF58C56E), width: 1.5)
                    : null,
                boxShadow: [
                  BoxShadow(
                      color: Colors.grey.withOpacity(0.08),
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
                    // Rank Icons
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

                    // Avatar
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage:
                          photoUrl != null ? NetworkImage(photoUrl) : null,
                      child: photoUrl == null
                          ? const Icon(Icons.person,
                              color: Colors.grey, size: 20)
                          : null,
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
                color: isUnlocked ? null : Colors.black.withOpacity(0.2),
                colorBlendMode: isUnlocked ? null : BlendMode.srcATop),
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
