import 'package:flutter/material.dart';

// --- 1. ABOUT US PAGE ---
class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("About Us",
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF58C56E),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Logo
            Image.asset('assets/images/hhlogo.png', height: 100),
            const SizedBox(height: 20),

            const Text(
              "HearingHands",
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF58C56E)),
            ),
            const Text(
              "Version 1.0.0",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 30),

            const Text(
              "Our Mission",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "HearingHands is designed to bridge the gap between the hearing and the Deaf community. By gamifying the learning process, we make Sign Language accessible, fun, and engaging for everyone.",
              textAlign: TextAlign.center,
              style:
                  TextStyle(fontSize: 16, height: 1.5, color: Colors.black87),
            ),

            const SizedBox(height: 30),
            const Divider(),
            const SizedBox(height: 30),

            const Text(
              "Meet the Team",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            _buildTeamMember("Your Name", "Lead Developer"),
            _buildTeamMember("Teammate 1", "UI/UX Designer"),
            _buildTeamMember("Teammate 2", "Researcher"),

            const SizedBox(height: 40),
            const Text("© 2026 HearingHands Team",
                style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamMember(String name, String role) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.person, color: Color(0xFF58C56E), size: 20),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(role,
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }
}

// --- 2. FAQ PAGE ---
class FAQPage extends StatelessWidget {
  const FAQPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("Help & FAQ",
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF58C56E),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          FAQItem(
            question: "Is this app free?",
            answer:
                "Yes! HearingHands is completely free to use for all learners.",
          ),
          FAQItem(
            question: "Do I need internet access?",
            answer:
                "You need internet to save your progress, view the leaderboard, and sign in. However, some games may work offline.",
          ),
          FAQItem(
            question: "How do I reset my password?",
            answer:
                "Go to Profile > Reset Password. We will send a secure link to your email address.",
          ),
          FAQItem(
            question: "How are points calculated?",
            answer:
                "You earn points by completing lessons and playing games like Sign Sprint. Faster times equal higher scores!",
          ),
          FAQItem(
            question: "Can I delete my account?",
            answer:
                "Yes. We respect your privacy. Go to Profile > Delete Account to permanently remove your data.",
          ),
        ],
      ),
    );
  }
}

class FAQItem extends StatelessWidget {
  final String question;
  final String answer;

  const FAQItem({super.key, required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 5,
              offset: const Offset(0, 2))
        ],
      ),
      child: ExpansionTile(
        title: Text(question,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        textColor: const Color(0xFF58C56E),
        iconColor: const Color(0xFF58C56E),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(answer,
                style: const TextStyle(height: 1.5, color: Colors.black87)),
          ),
        ],
      ),
    );
  }
}
