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

  // Default Image (You can later update this to pull from Firebase Storage)
  String? profileImage = 'assets/images/profile.jpg';

  @override
  void initState() {
    super.initState();
    _checkAuthAndFetchData();
  }

  // 2. Logic to decide: Are we a Guest or a User?
  Future<void> _checkAuthAndFetchData() async {
    // Listen to auth changes (Real-time update)
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
      print("Error fetching profile: $e");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // 4. MAIN BUILD: The Switcher
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.green)),
      );
    }

    // SWITCH: Guest vs User
    if (currentUser == null) {
      return _buildGuestView();
    } else {
      return _buildUserProfileView();
    }
  }

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
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.lock_person_rounded,
                    size: 80, color: Colors.green),
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

              // Sign Up Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF58C56E),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const CreateAccountScreen()));
                  },
                  child: const Text("Create Free Account",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 16),

              // Sign In Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Colors.grey),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
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
  // VIEW 2: USER PROFILE (Your Original Design)
  // ==========================================
  Widget _buildUserProfileView() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),

              // ---- Editable Profile Picture ----
              GestureDetector(
                onTap: _openPhotoOptions,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.green.shade100,
                      // Logic: Use asset if variable set, otherwise user default
                      backgroundImage: profileImage != null
                          ? AssetImage(profileImage!)
                          : null,
                      child: profileImage == null
                          ? Icon(Icons.person,
                              size: 55, color: Colors.grey.shade600)
                          : null,
                    ),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt,
                          size: 20, color: Colors.white),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ---- Name (Fetched from Firestore) ----
              Text(
                userData?['fullName'] ?? 'HearingHands User', // Fallback
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 6),

              // ---- Email (Fetched from Auth) ----
              Text(
                currentUser?.email ?? 'No Email',
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 25),

              // ---- Stats card (Dynamic Data) ----
              _statsCard(),

              const SizedBox(height: 30),

              // Options
              _profileOption(Icons.edit, 'Edit Profile', () {}),
              _profileOption(Icons.lock, 'Change Password', () {}),
              _profileOption(Icons.help, 'Help & Support', () {}),

              // LOGOUT
              _profileOption(Icons.logout, 'Logout', _confirmLogout),
            ],
          ),
        ),
      ),
    );
  }

  // ---- Logout Confirmation ----
  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            "Logout",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text("Are you sure you want to logout?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // close dialog
                _logout(); // Real Firebase Logout
              },
              child: const Text("Logout", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  // ---- Actual logout function ----
  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();

    // Optional: Reset state or navigate
    if (mounted) {
      // Since we have an auth listener, the UI might update automatically,
      // but typically you redirect to Splash or Home
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => const SplashScreen()));
    }
  }

  // ---- Bottom Sheet (Kept UI only) ----
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
            Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 20),
            _sheetOption(
                Icons.photo, "View Photo", () => Navigator.pop(context)),
            _sheetOption(
                Icons.camera_alt, "Change Photo", () => Navigator.pop(context)),
            const SizedBox(height: 10),
          ],
        );
      },
    );
  }

  Widget _sheetOption(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.green),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      onTap: onTap,
    );
  }

  // ---- Stats Card (Updated with Real Data Check) ----
  Widget _statsCard() {
    // Get values from Firestore map or default to "0"
    String streak = userData?['streak']?.toString() ?? "0";
    String activeDays = userData?['activeDays']?.toString() ?? "0";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _statItemWithImage(
            'assets/images/fire.png',
            'Streak',
            '$streak Days', // Dynamic
          ),
          Container(width: 1, height: 40, color: Colors.grey.shade300),
          _statItemWithImage(
            'assets/images/calendar.png',
            'Active Days',
            '$activeDays Days', // Dynamic
          ),
        ],
      ),
    );
  }

  Widget _statItemWithImage(String imagePath, String label, String value) {
    return Column(
      children: [
        Image.asset(
          imagePath, width: 45, height: 45,
          // Add error builder just in case image is missing
          errorBuilder: (c, e, s) => const Icon(Icons.error, color: Colors.red),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _profileOption(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 6),
      leading: Icon(icon, size: 26, color: Colors.green),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, color: Colors.black),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
