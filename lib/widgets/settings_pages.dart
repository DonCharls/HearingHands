import 'package:flutter/material.dart';

// --- 1. ABOUT US PAGE ---
class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Light grey background
      appBar: AppBar(
        title: const Text("About Us",
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF58C56E),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Logo with soft edges
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset('assets/images/hearinglogo.jpg', height: 100),
            ),
            const SizedBox(height: 16),
            const Text(
              "HearingHands",
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF58C56E)),
            ),
            const Text("Version 1.0.0", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 32),

            // Mission & Vision Cards
            _buildInfoCard(
              context,
              title: "Our Mission",
              icon: Icons.rocket_launch,
              content:
                  "To bridge the communication gap between the hearing and the Deaf community by making FSL learning fun, accessible, and engaging through technology.",
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              context,
              title: "Our Vision",
              icon: Icons.visibility,
              content:
                  "A future where every Filipino is empowered to communicate in Sign Language, fostering a truly inclusive and barrier-free society.",
            ),

            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 32),

            const Text("Meet the Team",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            _buildTeamMember(
              name: "Emelie C. Abendan",
              primaryRole: "Project Manager / Technical Writer",
              subRole: "Documentation & System Planning",
            ),

            _buildTeamMember(
              name: "Don Charls M. Bibat",
              primaryRole: "Lead Developer / UI/UX Designer",
              subRole: "Full Stack Dev & Graphics",
            ),

            _buildTeamMember(
              name: "Jaylord L. Benlot",
              primaryRole: "Quality Assurance Specialist",
              subRole: "System Testing & Bug Tracking",
            ),

            const SizedBox(height: 40),
            const Text("© 2026 HearingHands Team",
                style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  // Modern Card Widget for Mission/Vision
  Widget _buildInfoCard(BuildContext context,
      {required String title,
      required IconData icon,
      required String content}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: const Color(0xFF58C56E), size: 20),
              const SizedBox(width: 8),
              Text(title,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          Text(content,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 15, height: 1.5, color: Colors.black87)),
        ],
      ),
    );
  }

  // Clean Team Member Widget
  Widget _buildTeamMember(
      {required String name,
      required String primaryRole,
      required String subRole}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFF58C56E).withOpacity(0.1),
            child: const Icon(Icons.person, color: Color(0xFF58C56E)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                Text(primaryRole,
                    style: const TextStyle(
                        color: Color(0xFF58C56E),
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
                Text(subRole,
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- 2. FAQ PAGE (UPDATED WITH CATEGORIES) ---
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
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // --- GETTING STARTED ---
          _buildCategoryHeader("Getting Started"),
          const FAQItem(
            question: "What is HearingHands?",
            answer:
                "HearingHands is an interactive educational mobile app designed to teach Filipino Sign Language (FSL) through gamified lessons and challenges. Our goal is to make learning FSL accessible and fun for everyone.",
          ),
          const FAQItem(
            question: "How do I unlock new lessons?",
            answer:
                "Lessons unlock one by one. Once you finish a lesson and pass its mini-quiz, the next one will automatically become available.",
          ),

          const SizedBox(height: 10),

          // --- LEARNING TIPS ---
          _buildCategoryHeader("Learning Tips"),
          const FAQItem(
            question: "Which hand should I use?",
            answer:
                "You should use your 'dominant' hand (the hand you write with). If you are right-handed, use your right hand for main movements.",
          ),
          const FAQItem(
            question: "Do facial expressions matter?",
            answer:
                "Yes! In FSL, facial expressions are part of the grammar. They help convey the emotion and intensity of the sign.",
          ),

          const SizedBox(height: 10),

          // --- GAMES & SCORING ---
          _buildCategoryHeader("Games & Scoring"),
          const FAQItem(
            question: "How are points calculated?",
            answer:
                "You earn points by completing lessons and playing Sign Sprint. In Memory Match, we track your 'Moves'—lower is better!",
          ),
          const FAQItem(
            question: "Do I need internet access?",
            answer:
                "You need internet to sync your progress, view the leaderboard, and watch lesson videos. However, cached games may work offline.",
          ),

          const SizedBox(height: 10),

          // --- ACCOUNT SETTINGS ---
          _buildCategoryHeader("Account Settings"),
          const FAQItem(
            question: "How do I reset my password?",
            answer:
                "Go to Profile > Settings. You can request a secure password reset link to be sent to your email.",
          ),
          const FAQItem(
            question: "Can I delete my account?",
            answer:
                "Yes. We respect your privacy. Go to Profile > Delete Account to permanently remove your data.",
          ),

          const SizedBox(height: 30),

          // --- SUPPORT FOOTER ---
          const Column(
            children: [
              Text("Still need help?",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              SizedBox(height: 5),
              Text("Contact us at support@hearinghands.ph",
                  style: TextStyle(color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildCategoryHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 5, left: 5),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: Color(0xFF58C56E),
          fontWeight: FontWeight.bold,
          letterSpacing: 1.1,
          fontSize: 12,
        ),
      ),
    );
  }
}

// --- 3. FAQ ITEM WIDGET ---
class FAQItem extends StatelessWidget {
  final String question;
  final String answer;

  const FAQItem({super.key, required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Theme(
        // Removes the default divider line when expanded
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(question,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
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
      ),
    );
  }
}
