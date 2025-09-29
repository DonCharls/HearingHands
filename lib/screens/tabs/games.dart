import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Games extends StatefulWidget {
  const Games({super.key});

  @override
  State<Games> createState() => _GamesState();
}

class _GamesState extends State<Games> {
  bool hasStartedLearning = false;
  int lessonsCompleted = 0;
  int dailyStreak = 0;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      lessonsCompleted = prefs.getInt('lessonsCompleted') ?? 0;
      dailyStreak = prefs.getInt('dailyStreak') ?? 0;
      hasStartedLearning = lessonsCompleted > 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6FDF8), // subtle light green background
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('HearingHands'),
        backgroundColor: const Color(0xFF58C56E),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: hasStartedLearning
            ? _buildReturningUserContent()
            : _buildFirstTimeUserContent(),
      ),
    );
  }

  Widget _buildFirstTimeUserContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Welcome to HearingHands!",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF213F28),
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          "Start your journey learning Filipino Sign Language.",
          style: TextStyle(fontSize: 17, color: Colors.black87),
        ),
        const SizedBox(height: 30),
        _buildCTAButton(
          icon: Icons.rocket_launch,
          label: "Start your first lesson",
          onPressed: () => Navigator.pushNamed(context, '/lessons/start'),
        ),
        const SizedBox(height: 16),
        _buildOutlineButton(
          icon: Icons.menu_book_outlined,
          label: "Explore all lessons",
          onPressed: () => Navigator.pushNamed(context, '/lessons'),
        ),
        const SizedBox(height: 16),
        _buildOutlineButton(
          icon: Icons.translate,
          label: "Try translating something",
          onPressed: () => Navigator.pushNamed(context, '/translate'),
        ),
        const SizedBox(height: 40),
        _buildTipCard(
            "💡 Did you know?", "You can use fingerspelling to sign any name!"),
      ],
    );
  }

  Widget _buildReturningUserContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "👋 Welcome back!",
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Color(0xFF213F28),
          ),
        ),
        const SizedBox(height: 8),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.check_circle,
                        color: Color(0xFF58C56E), size: 22),
                    const SizedBox(width: 10),
                    Text(
                      "Lessons completed: $lessonsCompleted",
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.bolt_rounded,
                        color: Color(0xFF4F965E), size: 22),
                    const SizedBox(width: 10),
                    Text(
                      "Streak: $dailyStreak days",
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 30),
        _buildCTAButton(
          icon: Icons.play_arrow_rounded,
          label: "Continue where you left off",
          onPressed: () => Navigator.pushNamed(context, '/lessons/continue'),
        ),
        const SizedBox(height: 16),
        _buildOutlineButton(
          icon: Icons.menu_book_outlined,
          label: "Browse all lessons",
          onPressed: () => Navigator.pushNamed(context, '/lessons'),
        ),
        const SizedBox(height: 16),
        _buildOutlineButton(
          icon: Icons.translate,
          label: "Start a translation",
          onPressed: () => Navigator.pushNamed(context, '/translate'),
        ),
        const SizedBox(height: 40),
        _buildTipCard("💡 Tip", "Keep learning daily to grow your streak!"),
      ],
    );
  }

  Widget _buildCTAButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 24),
      label: Text(label, style: const TextStyle(fontSize: 16)),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF58C56E),
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Widget _buildOutlineButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton.icon(
      icon: Icon(icon, size: 22, color: const Color(0xFF58C56E)),
      label: Text(
        label,
        style: const TextStyle(fontSize: 16, color: Color(0xFF58C56E)),
      ),
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Color(0xFF58C56E), width: 2),
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Widget _buildTipCard(String title, String message) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F9EF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb_outline, color: Color(0xFF58C56E)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "$title\n$message",
              style: const TextStyle(fontSize: 15, color: Color(0xFF213F28)),
            ),
          ),
        ],
      ),
    );
  }
}
