import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Ensure these imports match your actual file structure
import '../create_account.dart';
import '../sign_in.dart';
import '../../splash_screen.dart';
import 'awards.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
// --- 1. STATE VARIABLES ---
  User? currentUser;
  Map<String, dynamic>? userData;
  bool isLoading = false;

  // Default picture points to the first numbered avatar
  String profileImage = 'assets/images/avatar/avatar_1.png';

  // Generate list of avatars (1 to 32)
  final List<String> availableAvatars = List.generate(32, (index) {
    return 'assets/images/avatar/avatar_${index + 1}.png';
  });

  @override
  void initState() {
    super.initState();
    _checkAuthAndFetchData();
  }

  // --- 2. LOGIC SECTION ---

  Future<void> _checkAuthAndFetchData() async {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (mounted) {
        setState(() => currentUser = user);
        if (user != null) _fetchUserData(user.uid);
      }
    });
  }

  Future<void> _fetchUserData(String uid) async {
    setState(() => isLoading = true);
    try {
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (userDoc.exists && mounted) {
        setState(() {
          userData = userDoc.data() as Map<String, dynamic>;
          // Load saved avatar if exists, otherwise keep default
          if (userData!['profileImage'] != null) {
            profileImage = userData!['profileImage'];
          }
        });
      }
    } catch (e) {
      debugPrint("Error fetching profile: $e");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _updateAvatar(String assetPath) async {
    Navigator.pop(context); // Close sheet
    setState(() => profileImage = assetPath); // Optimistic update

    if (currentUser != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .update({'profileImage': assetPath});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Avatar updated!"),
            duration: Duration(milliseconds: 800)),
      );
    }
  }

  int _calculateSignsLearned() {
    if (userData == null) return 0;
    int totalSigns = 0;
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
      if (userData![key] == true) totalSigns += count;
    });
    return totalSigns;
  }

  void _showAvatarPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 500,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text("Choose your Avatar",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                ),
                itemCount: availableAvatars.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => _updateAvatar(availableAvatars[index]),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: Colors.grey.shade200, width: 2),
                        image: DecorationImage(
                            image: AssetImage(availableAvatars[index])),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (_) => const SplashScreen()));
              },
              child: const Text("Logout", style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }

  // --- 3. MAIN BUILD ---
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF58C56E)),
        ),
      );
    }

    if (currentUser == null) {
      return _buildGuestView();
    }

    // Calculations for UI
    final int signsCount = _calculateSignsLearned();
    final int streakCount = userData?['streak'] ?? 0;
    final int currentLevel = (signsCount / 10).floor() + 1;
    final int nextLevelGoal = currentLevel * 10;
    final double progressPercent = (signsCount % 10) / 10;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              ProfileHeader(
                name: userData?['fullName'] ?? 'Learner',
                imagePath: profileImage,
                level: currentLevel,
                signs: signsCount,
                goal: nextLevelGoal,
                progress: progressPercent,
                onEdit: _showAvatarPicker,
              ),
              const SizedBox(height: 24),
              StatsGrid(streak: streakCount, signs: signsCount),
              const SizedBox(height: 24),
              const AchievementsTeaser(),
              const SizedBox(height: 30),
              // Settings Group
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4))
                  ],
                ),
                child: Column(
                  children: [
                    ProfileMenuOption(
                        icon: Icons.edit,
                        title: 'Change Avatar',
                        onTap: _showAvatarPicker),
                    Divider(height: 1, color: Colors.grey.shade100),
                    ProfileMenuOption(
                        icon: Icons.lock,
                        title: 'Change Password',
                        onTap: () {}),
                    Divider(height: 1, color: Colors.grey.shade100),
                    ProfileMenuOption(
                        icon: Icons.logout,
                        title: 'Logout',
                        onTap: _confirmLogout,
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

  // --- UPDATED GUEST VIEW (Matches Awards Design) ---
  Widget _buildGuestView() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 1. Image
              Image.asset(
                'assets/images/locked.png',
                width: 180,
                height: 180,
                fit: BoxFit.contain,
              ),

              const SizedBox(height: 30),

              // 2. Title - Green & Bold
              const Text(
                "Profile Locked",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF58C56E), // Matches Brand Color
                ),
              ),

              const SizedBox(height: 15),

              // 3. Body text
              const Text(
                "Log in to track your streak, customize your avatar, and see your progress statistics.",
                textAlign: TextAlign.center,
                style:
                    TextStyle(fontSize: 15, color: Colors.black54, height: 1.5),
              ),

              const SizedBox(height: 40),

              // 4. Primary Button: Create Account (Green)
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
                  child: const Text(
                    "Create an Account",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // 5. Secondary Button: Sign In (Outlined)
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
                  child: const Text(
                    "Sign In",
                    style: TextStyle(
                      color: Color(0xFF58C56E),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================================
//   REFACTORED WIDGETS
// ==========================================================

class ProfileHeader extends StatelessWidget {
  final String name;
  final String imagePath;
  final int level;
  final int signs;
  final int goal;
  final double progress;
  final VoidCallback onEdit;

  const ProfileHeader({
    super.key,
    required this.name,
    required this.imagePath,
    required this.level,
    required this.signs,
    required this.goal,
    required this.progress,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF58C56E), width: 3),
              ),
              child: CircleAvatar(
                radius: 55,
                backgroundColor: Colors.grey.shade200,
                backgroundImage: AssetImage(imagePath),
              ),
            ),
            GestureDetector(
              onTap: onEdit,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF58C56E),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(Icons.edit, size: 16, color: Colors.white),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(name,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        SizedBox(
          width: 200,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Level $level",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF58C56E))),
                  Text("$signs / $goal Signs",
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progress == 0 ? 0.05 : progress,
                  minHeight: 8,
                  backgroundColor:
                      const Color(0xFF58C56E).withValues(alpha: 0.2),
                  color: const Color(0xFF58C56E),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class StatsGrid extends StatelessWidget {
  final int streak;
  final int signs;

  const StatsGrid({super.key, required this.streak, required this.signs});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildCard('Streak', '$streak Days', '🔥'),
        const SizedBox(width: 12),
        _buildCard('Signs', '$signs', '🤟'),
        const SizedBox(width: 12),
        _buildCard('Rank', '#--', '🏆'),
      ],
    );
  }

  Widget _buildCard(String label, String value, String emoji) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ],
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 8),
            Text(value,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text(label,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
          ],
        ),
      ),
    );
  }
}

class AchievementsTeaser extends StatelessWidget {
  const AchievementsTeaser({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => const Awards()));
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [Color(0xFF58C56E), Color(0xFF3EA353)]),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: const Color(0xFF58C56E).withValues(alpha: 0.4),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle),
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
}

class ProfileMenuOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isDestructive;

  const ProfileMenuOption({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDestructive
              ? Colors.red.withValues(alpha: 0.1)
              : const Color(0xFF58C56E).withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon,
            size: 20,
            color: isDestructive ? Colors.red : const Color(0xFF58C56E)),
      ),
      title: Text(title,
          style: TextStyle(
              fontWeight: FontWeight.w500,
              color: isDestructive ? Colors.red : Colors.black87)),
      trailing:
          Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey.shade400),
      onTap: onTap,
    );
  }
}
