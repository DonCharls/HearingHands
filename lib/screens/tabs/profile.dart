import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../splash_screen.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String? profileImage = 'assets/images/profile.jpg'; // default image

  @override
  Widget build(BuildContext context) {
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
                      backgroundImage: profileImage != null
                          ? AssetImage(profileImage!)
                          : null,
                      child: profileImage == null
                          ? Icon(Icons.person,
                              size: 55, color: Colors.grey.shade600)
                          : null,
                    ),

                    // Camera icon
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

              // Name
              const Text(
                'Don Charls Bibat',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 6),

              // Email
              const Text(
                'doncharls@gmail.com',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 25),

              // Stats card
              _statsCard(),

              const SizedBox(height: 30),

              // Options
              _profileOption(Icons.edit, 'Edit Profile', () {}),
              _profileOption(Icons.lock, 'Change Password', () {}),
              _profileOption(Icons.help, 'Help & Support', () {}),

              // LOGOUT WITH CONFIRMATION
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
              onPressed: () {
                Navigator.pop(context); // close dialog
              },
              child: const Text(
                "Cancel",
                style: TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // close dialog
                _logout(); // navigate to onboarding
              },
              child: const Text(
                "Logout",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  // ---- Actual logout function ----
  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('seenOnboarding'); // reset onboarding
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SplashScreen()),
    );
  }

  // ---- Bottom Sheet ----
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
            _sheetOption(Icons.photo, "View Photo", () {
              Navigator.pop(context);
            }),
            _sheetOption(Icons.camera_alt, "Change Photo", () {
              Navigator.pop(context);
            }),
            if (profileImage != null)
              _sheetOption(Icons.delete, "Remove Photo", () {
                setState(() => profileImage = null);
                Navigator.pop(context);
              }),
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

  // ---- Stats Card ----
  Widget _statsCard() {
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
            '2 days',
          ),
          Container(width: 1, height: 40, color: Colors.grey.shade300),
          _statItemWithImage(
            'assets/images/calendar.png',
            'Active Days',
            '5 days',
          ),
        ],
      ),
    );
  }

  Widget _statItemWithImage(String imagePath, String label, String value) {
    return Column(
      children: [
        Image.asset(imagePath, width: 45, height: 45),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
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

  // ---- Options ----
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
