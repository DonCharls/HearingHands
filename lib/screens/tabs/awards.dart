import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../create_account.dart';
import '../sign_in.dart';
import '../../models/badge_data.dart';

class Awards extends StatefulWidget {
  const Awards({super.key});

  @override
  State<Awards> createState() => _AwardsState();
}

class _AwardsState extends State<Awards> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? "";

  // --- STATE: LEADERBOARD FILTER ---
  // FIXED: Changed 'memoryLowestMoves' to 'memoryLowScore' to match the Game file
  String sortBy = 'signsLearned';

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
    if (currentUserId.isEmpty) return _buildGuestView();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("Achievements Hub",
            style: TextStyle(fontWeight: FontWeight.bold)),
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

  // --- GUEST VIEW (Unchanged) ---
  Widget _buildGuestView() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/locked.png',
                  width: 180, height: 180, fit: BoxFit.contain),
              const SizedBox(height: 30),
              const Text("Awards Locked",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF58C56E))),
              const SizedBox(height: 15),
              const Text(
                  "Sign in to track your badges, compete on the leaderboard, and save your game high scores.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 15, color: Colors.black54, height: 1.5)),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const CreateAccountScreen())),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF58C56E),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12))),
                  child: const Text("Create an Account",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SignInScreen())),
                  style: OutlinedButton.styleFrom(
                      side:
                          const BorderSide(color: Color(0xFF58C56E), width: 2),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12))),
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

  // --- TAB 1: BADGES (Unchanged) ---
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
        int unlockedCount = 0;
        for (var rule in allBadges) {
          if (rule['check'](userData)) unlockedCount++;
        }
        double progress =
            allBadges.isNotEmpty ? unlockedCount / allBadges.length : 0;

        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5))
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("$unlockedCount / ${allBadges.length} Unlocked",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
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
                        minHeight: 12,
                        backgroundColor: Colors.grey.shade200,
                        color: const Color(0xFF58C56E)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(20),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15),
                itemCount: allBadges.length,
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
                              offset: const Offset(0, 3))
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Opacity(
                            opacity: isUnlocked ? 1.0 : 0.3,
                            child: Image.asset(badge['image'],
                                height: 60,
                                errorBuilder: (_, __, ___) => const Icon(
                                    Icons.emoji_events,
                                    size: 40,
                                    color: Colors.grey)),
                          ),
                          const SizedBox(height: 12),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Text(badge['title'],
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: isUnlocked
                                        ? Colors.black87
                                        : Colors.grey)),
                          ),
                          if (!isUnlocked)
                            const Padding(
                                padding: EdgeInsets.only(top: 4),
                                child: Icon(Icons.lock,
                                    size: 12, color: Colors.grey)),
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
    // Logic: If filtering by Memory Moves, Lower is Better (Ascending).
    bool isMemoryMatch = sortBy == 'memoryLowScore';

    // QUERY BUILDER
    Query query = FirebaseFirestore.instance.collection('users').limit(20);

    // CRITICAL FIX:
    // If we are sorting by Memory Scores (Ascending), we MUST exclude 0.
    // Otherwise, users who haven't played (score 0) will be #1.
    if (isMemoryMatch) {
      query = query
          .where('memoryLowScore', isGreaterThan: 0)
          .orderBy('memoryLowScore', descending: false);
    } else {
      // Normal High Score logic
      query = query.orderBy(sortBy, descending: true);
    }

    return Column(
      children: [
        // 1. Filter Buttons
        Container(
          margin: const EdgeInsets.fromLTRB(16, 20, 16, 10),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.grey.shade300)),
          child: Row(
            children: [
              _buildFilterBtn("Learner", 'signsLearned'),
              _buildFilterBtn("Sprinter", 'gameHighScore'),
              // FIXED: Changed value key to 'memoryLowScore'
              _buildFilterBtn("Memory", 'memoryLowScore'),
            ],
          ),
        ),

        // 2. The List
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: query.snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData)
                return const Center(child: CircularProgressIndicator());
              final users = snapshot.data!.docs;

              if (users.isEmpty) {
                return Center(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                      Image.asset('assets/images/groupbear.png', height: 120),
                      const SizedBox(height: 20),
                      const Text("No scores yet!",
                          style: TextStyle(color: Colors.grey))
                    ]));
              }

              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 40),
                children: [
                  // 3. THE PODIUM (Top 3)
                  if (users.isNotEmpty) _buildPodium(users),

                  const SizedBox(height: 20),
                  const Text("All Learners",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 10),

                  // 4. The Rest of the List (Start from index 3)
                  if (users.length > 3)
                    ...List.generate(users.length - 3, (index) {
                      final actualIndex = index + 3; // Shift index
                      return _buildLeaderboardCard(
                          users[actualIndex], actualIndex);
                    }),

                  if (users.length <= 3)
                    const Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: Center(
                          child: Text("Join the race! Invite friends.",
                              style: TextStyle(color: Colors.grey))),
                    )
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  // --- 10/10 HELPER: THE PODIUM ---
  Widget _buildPodium(List<QueryDocumentSnapshot> users) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end, // Align bottom
      children: [
        // 2nd Place (Left)
        if (users.length > 1)
          Expanded(child: _buildPodiumSpot(users[1], 2, 90)),

        // 1st Place (Center - Biggest)
        Expanded(child: _buildPodiumSpot(users[0], 1, 110)),

        // 3rd Place (Right)
        if (users.length > 2)
          Expanded(child: _buildPodiumSpot(users[2], 3, 90)),
      ],
    );
  }

  Widget _buildPodiumSpot(
      QueryDocumentSnapshot user, int rank, double avatarSize) {
    final data = user.data() as Map<String, dynamic>;
    final name = data['fullName']?.split(" ")[0] ?? "User"; // First name only
    final score = data[sortBy] ?? 0;
    final isMe = user.id == currentUserId;

    // Dynamic Suffix
    String suffix = "";
    if (sortBy == 'signsLearned') suffix = " Signs";
    if (sortBy == 'gameHighScore') suffix = " Pts";
    // FIXED: Correct check
    if (sortBy == 'memoryLowScore') suffix = " Moves";

    Color crownColor = rank == 1
        ? const Color(0xFFFFD700)
        : (rank == 2 ? const Color(0xFFC0C0C0) : const Color(0xFFCD7F32));

    return Column(
      children: [
        if (rank == 1)
          const Icon(Icons.emoji_events, color: Color(0xFFFFD700), size: 30),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: crownColor, width: 3)),
          child: CircleAvatar(
            radius: avatarSize / 2,
            backgroundColor: Colors.grey.shade200,
            backgroundImage: (data['profileImage'] != null)
                ? AssetImage(data['profileImage'])
                : const AssetImage('assets/images/avatar/avatar_1.png'),
          ),
        ),
        const SizedBox(height: 8),
        Text(name,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isMe ? const Color(0xFF58C56E) : Colors.black87),
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
        Container(
          margin: const EdgeInsets.only(top: 4),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
              color: crownColor, borderRadius: BorderRadius.circular(12)),
          child: Text("$score$suffix",
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 10)),
        ),
        // Visual "Step"
        Container(
          height: rank == 1 ? 30 : 15, // 1st place stands higher
          width: 50,
          margin: const EdgeInsets.only(top: 10),
          decoration: BoxDecoration(
            color: crownColor.withValues(alpha: 0.2),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          ),
          child: Center(
              child: Text("$rank",
                  style: TextStyle(
                      color: crownColor, fontWeight: FontWeight.bold))),
        )
      ],
    );
  }

  Widget _buildFilterBtn(String title, String value) {
    bool isSelected = sortBy == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => sortBy = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF58C56E) : Colors.transparent,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            // Adjust font size if screen is small
            style: TextStyle(
                fontSize: 12,
                color: isSelected ? Colors.white : Colors.grey,
                fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildLeaderboardCard(QueryDocumentSnapshot user, int index) {
    final data = user.data() as Map<String, dynamic>;
    final isMe = user.id == currentUserId;

    // Dynamic Display
    String displayScore = "";
    if (sortBy == 'signsLearned')
      displayScore = "${data[sortBy] ?? 0} Signs";
    else if (sortBy == 'gameHighScore')
      displayScore = "${data[sortBy] ?? 0} Pts";
    else
      displayScore = "${data[sortBy] ?? '--'} Moves";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isMe ? const Color(0xFFF0FDF4) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isMe ? Border.all(color: const Color(0xFF58C56E)) : null,
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withValues(alpha: 0.05),
              blurRadius: 5,
              offset: const Offset(0, 2))
        ],
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          alignment: Alignment.center,
          child: Text("#${index + 1}",
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                  fontSize: 16)),
        ),
        title: Row(
          children: [
            CircleAvatar(
                radius: 18,
                backgroundColor: Colors.grey.shade200,
                backgroundImage: (data['profileImage'] != null)
                    ? AssetImage(data['profileImage'])
                    : const AssetImage('assets/images/avatar/avatar_1.png')),
            const SizedBox(width: 12),
            Expanded(
                child: Text(data['fullName'] ?? "Learner",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600))),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
              color: const Color(0xFFF5F7FA),
              borderRadius: BorderRadius.circular(12)),
          child: Text(displayScore,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.black87)),
        ),
      ),
    );
  }

  // --- POPUP DIALOG (Unchanged) ---
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
                          borderRadius: BorderRadius.circular(20))))
            else
              const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.lock, color: Colors.grey),
                SizedBox(width: 8),
                Text("Keep learning to unlock!",
                    style: TextStyle(
                        color: Colors.grey, fontWeight: FontWeight.bold))
              ])
          ],
        ),
      ),
    );
  }
}
