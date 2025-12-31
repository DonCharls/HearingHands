import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../create_account.dart';
import '../sign_in.dart';
import '../../splash_screen.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  // 1. Auth & Data Variables
  User? currentUser = FirebaseAuth.instance.currentUser;
  Map<String, dynamic>? userData;
  bool isLoading = false;

  // Default Image
  String? profileImage = 'assets/images/profile.jpg';

  @override
  void initState() {
    super.initState();
    _checkAuthAndFetchData();
  }

  // 2. Logic to decide: Are we a Guest or a User?
  Future<void> _checkAuthAndFetchData() async {
    // Listen to auth changes
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (mounted) {
        setState(() {
          currentUser = user;
        });
        if (user != null) {
          _fetchUserData(user.uid);
        }
      }
    });
  }

  // 3. Fetch Data from Firestore
  Future<void> _fetchUserData(String uid) async {
    setState(() => isLoading = true);
    try {
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (userDoc.exists && mounted) {
        setState(() {
          userData = userDoc.data() as Map<String, dynamic>;
        });
      }
    } catch (e) {
      debugPrint("Error fetching profile: $e");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // --- NEW: LOGIC TO CALCULATE SIGNS LEARNED ---
  int _calculateSignsLearned() {
    if (userData == null) return 0;

    int totalSigns = 0;
    // Map your lesson keys to the number of letters in that lesson
    // Example: 'ABC' has 3 letters. 'YZ' has 2.
    Map<String, int> lessonValues = {
      'lesson_abc_done': 3,
      'lesson_def_done': 3,
      'lesson_ghi_done': 3,
      'lesson_jkl_done': 3,
      'lesson_mno_done': 3,
      'lesson_pqr_done': 3,
      'lesson_stu_done': 3,
      'lesson_vwx_done': 3,
      'lesson_yz_done': 2,
    };

    lessonValues.forEach((key, count) {
      // Check if the key exists in Firestore and is set to true
      if (userData!.containsKey(key) && userData![key] == true) {
        totalSigns += count;
      }
    });

    return totalSigns;
  }

  // 4. MAIN BUILD: The Switcher
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body:
            Center(child: CircularProgressIndicator(color: Color(0xFF58C56E))),
      );
    }

    if (currentUser == null) {
      return _buildGuestView();
    } else {
      return _buildUserProfileView();
    }
  }

  // ==========================================
  // VIEW 1: GUEST VIEW (Unchanged Logic, better styling)
  // ==========================================
  Widget _buildGuestView() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF58C56E).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.lock_person_rounded,
                    size: 60, color: Color(0xFF58C56E)),
              ),
              const SizedBox(height: 24),
              const Text(
                "Profile Locked",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                "Create a free account to track your daily streak, save your progress, and see your stats!",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF58C56E),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const CreateAccountScreen()));
                  },
                  child: const Text("Create Account",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SignInScreen()));
                  },
                  child: const Text("I already have an account",
                      style: TextStyle(
                          color: Colors.black87, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // VIEW 2: NEW "HERO" USER DASHBOARD
  // ==========================================
  Widget _buildUserProfileView() {
    // Dynamic Calculations
    final int signsCount = _calculateSignsLearned();
    final int streakCount = userData?['streak'] ?? 0;
    // Calculate Level: Simple logic (e.g., 10 signs = Level 2)
    final int currentLevel = (signsCount / 10).floor() + 1;
    final int nextLevelGoal = currentLevel * 10;
    final double progressPercent = (signsCount % 10) / 10;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Off-white background
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // 1. HEADER: Avatar + Name + Level
              _buildHeader(
                  currentLevel, signsCount, nextLevelGoal, progressPercent),

              const SizedBox(height: 24),

              // 2. DASHBOARD: The Stats Grid
              _buildStatsGrid(streakCount, signsCount),

              const SizedBox(height: 24),

              // 3. GAMIFICATION: Achievements Teaser
              _buildAchievementsTeaser(),

              const SizedBox(height: 30),

              // 4. SETTINGS SECTION (Grouped in a Card)
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4))
                  ],
                ),
                child: Column(
                  children: [
                    _profileOption(Icons.edit, 'Edit Profile', () {}),
                    Divider(height: 1, color: Colors.grey.shade100),
                    _profileOption(Icons.lock, 'Change Password', () {}),
                    Divider(height: 1, color: Colors.grey.shade100),
                    _profileOption(Icons.help, 'Help & Support', () {}),
                    Divider(height: 1, color: Colors.grey.shade100),
                    _profileOption(Icons.logout, 'Logout', _confirmLogout,
                        isDestructive: true),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- COMPONENT: Header with Level Bar ---
  Widget _buildHeader(int level, int signs, int goal, double percent) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: const Color(0xFF58C56E), width: 3), // Level border
              ),
              child: CircleAvatar(
                radius: 50,
                backgroundImage:
                    profileImage != null ? AssetImage(profileImage!) : null,
                backgroundColor: Colors.grey.shade200,
                child: profileImage == null
                    ? const Icon(Icons.person, size: 50, color: Colors.grey)
                    : null,
              ),
            ),
            // Edit Photo Icon
            GestureDetector(
              onTap: _openPhotoOptions,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                    color: Color(0xFF58C56E), shape: BoxShape.circle),
                child:
                    const Icon(Icons.camera_alt, size: 16, color: Colors.white),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          userData?['fullName'] ?? 'HearingHands User',
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        // Level Progress Bar
        SizedBox(
          width: 220,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Level $level",
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF58C56E))),
                  Text("$signs / $goal Signs",
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value:
                      percent == 0 ? 0.05 : percent, // Always show a tiny bit
                  backgroundColor: const Color(0xFF58C56E).withOpacity(0.2),
                  color: const Color(0xFF58C56E),
                  minHeight: 8,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- COMPONENT: 3-Column Stats Grid ---
  Widget _buildStatsGrid(int streak, int signs) {
    return Row(
      children: [
        _statCard('Streak', '$streak Days', '🔥'),
        const SizedBox(width: 12),
        _statCard('Signs', '$signs', '🤟'), // Now Dynamic!
        const SizedBox(width: 12),
        // Rank is still static for now until we build Leaderboard
        _statCard('Rank', '#---', '🏆'),
      ],
    );
  }

  Widget _statCard(String label, String value, String emoji) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.green.withOpacity(0.08),
                blurRadius: 15,
                offset: const Offset(0, 5))
          ],
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 10),
            Text(value,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(label,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
          ],
        ),
      ),
    );
  }

  // --- COMPONENT: Achievements Link ---
  Widget _buildAchievementsTeaser() {
    return GestureDetector(
      onTap: () {
        // TODO: Navigate to Achievements Screen
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Leaderboard coming next!")));
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [Color(0xFF58C56E), Color(0xFF3EA353)]),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: const Color(0xFF58C56E).withOpacity(0.4),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
              child: const Icon(Icons.emoji_events, color: Colors.white),
            ),
            const SizedBox(width: 16),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Achievements",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
                Text("Check your rank",
                    style: TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
          ],
        ),
      ),
    );
  }

  // --- COMPONENT: Standard Option Tile ---
  Widget _profileOption(IconData icon, String title, VoidCallback onTap,
      {bool isDestructive = false}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDestructive
              ? Colors.red.withOpacity(0.1)
              : const Color(0xFF58C56E).withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon,
            size: 20,
            color: isDestructive ? Colors.red : const Color(0xFF58C56E)),
      ),
      title: Text(
        title,
        style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: isDestructive ? Colors.red : Colors.black87),
      ),
      trailing:
          Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey.shade400),
      onTap: onTap,
    );
  }

  // ---- LOGOUT & PHOTO LOGIC (Kept same as before) ----
  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Logout"),
          content: const Text("Are you sure you want to logout?"),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child:
                    const Text("Cancel", style: TextStyle(color: Colors.grey))),
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _logout();
                },
                child:
                    const Text("Logout", style: TextStyle(color: Colors.red))),
          ],
        );
      },
    );
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => const SplashScreen()));
    }
  }

  void _openPhotoOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 5, color: Colors.grey.shade300),
            const SizedBox(height: 20),
            ListTile(
                leading: const Icon(Icons.photo, color: Colors.green),
                title: const Text("View Photo"),
                onTap: () => Navigator.pop(context)),
            ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.green),
                title: const Text("Change Photo"),
                onTap: () => Navigator.pop(context)),
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }
}
