import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// SCREEN IMPORTS
import '../../widgets/settings_pages.dart';
import '../create_account.dart';
import '../sign_in.dart';
import '../../splash_screen.dart';
import 'awards.dart';
import '../../widgets/profile_components.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  // --- 1. STATE VARIABLES ---
  User? currentUser;
  Map<String, dynamic>? userData;
  bool isLoading = true;
  int userGlobalRank = 0;

  String profileImage = 'assets/images/avatar/avatar_1.png';

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
        if (user != null) {
          _fetchUserData(user.uid);
        } else {
          setState(() => isLoading = false);
        }
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
          if (userData!['profileImage'] != null) {
            profileImage = userData!['profileImage'];
          }
        });
        await _calculateGlobalRank();
      }
    } catch (e) {
      debugPrint("Error fetching profile: $e");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _calculateGlobalRank() async {
    try {
      QuerySnapshot allUsers = await FirebaseFirestore.instance
          .collection('users')
          .orderBy('signsLearned', descending: true)
          .get();

      int rank = 1;
      for (var doc in allUsers.docs) {
        if (doc.id == currentUser!.uid) {
          break;
        }
        rank++;
      }
      if (mounted) setState(() => userGlobalRank = rank);
    } catch (e) {
      debugPrint("Error calculating rank: $e");
    }
  }

  void _editName() {
    TextEditingController nameController =
        TextEditingController(text: userData?['fullName']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Name"),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
              labelText: "Full Name", border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty) {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(currentUser!.uid)
                    .update({'fullName': nameController.text});

                setState(() {
                  if (userData != null) {
                    userData!['fullName'] = nameController.text;
                  }
                });
                if (mounted) Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF58C56E)),
            child: const Text("Save", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
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

  Future<void> _updateAvatar(String assetPath) async {
    Navigator.pop(context);
    setState(() => profileImage = assetPath);

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

  Future<void> _changePassword() async {
    if (currentUser?.email != null) {
      try {
        await FirebaseAuth.instance
            .sendPasswordResetEmail(email: currentUser!.email!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Reset link sent to ${currentUser!.email}"),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  void _deleteAccount() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Account"),
        content: const Text(
          "WARNING: This will permanently delete your badges, progress, and leaderboard rank. This action cannot be undone.",
          style: TextStyle(color: Colors.red),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              setState(() => isLoading = true);

              try {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(currentUser!.uid)
                    .delete();

                await currentUser!.delete();

                if (mounted) {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const SplashScreen()),
                      (route) => false);
                }
              } catch (e) {
                setState(() => isLoading = false);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            "Please log out and log in again to delete account (Security requirement).")),
                  );
                }
              }
            },
            child: const Text("DELETE",
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
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

  int _calculateSignsLearned() {
    if (userData == null) return 0;
    if (userData!.containsKey('signsLearned')) {
      return userData!['signsLearned'];
    }
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

  // --- 3. MAIN BUILD ---
  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return _buildGuestView();
    }

    final int signsCount = _calculateSignsLearned();
    final int streakCount = userData?['streak'] ?? 0;
    final int currentLevel = (signsCount / 10).floor() + 1;
    final int nextLevelGoal = currentLevel * 10;
    final double progressPercent = (signsCount % 10) / 10;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF58C56E)))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // CLEAN! Using imported widget
                    ProfileHeader(
                      name: userData?['fullName'] ?? 'Learner',
                      imagePath: profileImage,
                      level: currentLevel,
                      signs: signsCount,
                      goal: nextLevelGoal,
                      progress: progressPercent,
                      onEditAvatar: _showAvatarPicker,
                      onEditName: _editName,
                    ),
                    const SizedBox(height: 24),

                    // CLEAN! Using imported widget + Navigation callback
                    StatsGrid(
                      streak: streakCount,
                      signs: signsCount,
                      rank: userGlobalRank,
                      onRankTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const Awards()));
                      },
                    ),

                    const SizedBox(height: 24),

                    // CLEAN! Using imported widget
                    AchievementsTeaser(
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const Awards()));
                      },
                    ),

                    const SizedBox(height: 30),

                    // --- ACCOUNT SETTINGS ---
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
                              icon: Icons.image,
                              title: 'Change Avatar',
                              onTap: _showAvatarPicker),
                          Divider(height: 1, color: Colors.grey.shade100),
                          ProfileMenuOption(
                              icon: Icons.lock_reset,
                              title: 'Reset Password',
                              onTap: _changePassword),
                          Divider(height: 1, color: Colors.grey.shade100),
                          ProfileMenuOption(
                              icon: Icons.logout,
                              title: 'Logout',
                              onTap: _confirmLogout,
                              isDestructive: false),
                          Divider(height: 1, color: Colors.grey.shade100),
                          ProfileMenuOption(
                              icon: Icons.delete_forever,
                              title: 'Delete Account',
                              onTap: _deleteAccount,
                              isDestructive: true),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // --- NEW: SUPPORT & INFO SECTION ---
                    const Padding(
                      padding: EdgeInsets.only(left: 8, bottom: 8),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text("Support & Info",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey)),
                      ),
                    ),

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
                              icon: Icons.help_outline,
                              title: 'Help & FAQ',
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => const FAQPage()));
                              }),
                          Divider(height: 1, color: Colors.grey.shade100),
                          ProfileMenuOption(
                              icon: Icons.info_outline,
                              title: 'About Us',
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => const AboutUsPage()));
                              }),
                          Divider(height: 1, color: Colors.grey.shade100),
                          ProfileMenuOption(
                              icon: Icons.privacy_tip_outlined,
                              title: 'Privacy Policy',
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            "Visit hearinghands.com/privacy")));
                              }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
      ),
    );
  }

  // --- GUEST VIEW (Keeping this here as it's specific to the screen logic) ---
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
              const Text("Profile Locked",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF58C56E))),
              const SizedBox(height: 15),
              const Text(
                "Log in to track your streak, customize your avatar, and see your progress statistics.",
                textAlign: TextAlign.center,
                style:
                    TextStyle(fontSize: 15, color: Colors.black54, height: 1.5),
              ),
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
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0),
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
}
