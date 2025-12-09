import 'package:flutter/material.dart';

class Awards extends StatelessWidget {
  const Awards({super.key});

  final List<Map<String, dynamic>> awards = const [
    {
      "title": "Trailblazer",
      "unlocked": true,
      "description": "Log in for the first time.",
      "image": "assets/images/awards/trailblazer.png",
    },
    {
      "title": "Quick Learner",
      "unlocked": true,
      "description": "Complete your first lesson.",
      "image": "assets/images/awards/quicklearner.png",
    },
    {
      "title": "Triple Threat",
      "unlocked": true,
      "description": "Finish 3 lessons.",
      "image": "assets/images/awards/triplethreat.png",
    },
    {
      "title": "Lesson Master",
      "unlocked": false,
      "description": "Finish 5 lessons.",
      "image": "assets/images/awards/lessonmaster.png",
    },
    {
      "title": "Alphabet Ace",
      "unlocked": true,
      "description": "Complete all Alphabet lessons.",
      "image": "assets/images/awards/alphabetace.png",
    },
    {
      "title": "Two-Day Champ",
      "unlocked": true,
      "description": "Maintain a 2-day streak.",
      "image": "assets/images/awards/twodaychamp.png",
    },
    {
      "title": "Five-Day Champ",
      "unlocked": false,
      "description": "Maintain a 5-day streak.",
      "image": "assets/images/awards/fivedaychamp.png",
    },
    {
      "title": "Lucky Seven",
      "unlocked": false,
      "description": "Maintain a 7-day streak.",
      "image": "assets/images/awards/luckyseven.png",
    },
    {
      "title": "Dictionary Explorer",
      "unlocked": false,
      "description": "Use the dictionary feature.",
      "image": "assets/images/awards/dictionaryexplorer.png",
    },
    {
      "title": "Quiz Rookie",
      "unlocked": true,
      "description": "Complete your first quiz.",
      "image": "assets/images/awards/quizrookie.png",
    },
    {
      "title": "Quiz Whiz",
      "unlocked": false,
      "description": "Get a perfect quiz score.",
      "image": "assets/images/awards/quizwhiz.png",
    },
    {
      "title": "Two-Week Streaker",
      "unlocked": false,
      "description": "Maintain a 14-day streak.",
      "image": "assets/images/awards/twoweekstreaker.png",
    },
    {
      "title": "Greetings Guru",
      "unlocked": false,
      "description": "Complete all Greetings & Basics lessons.",
      "image": "assets/images/awards/greetingsguru.png",
    },
    {
      "title": "Number Ninja",
      "unlocked": false,
      "description": "Complete all Numbers & Counting lessons.",
      "image": "assets/images/awards/numberninja.png",
    },
    {
      "title": "Feelings Friend",
      "unlocked": false,
      "description": "Complete all Needs & Feelings lessons.",
      "image": "assets/images/awards/feelingsfriend.png",
    },
  ];

  void _showAwardPopup(BuildContext context, Map<String, dynamic> award) {
    showDialog(
      context: context,
      builder: (context) => Center(
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          child: Container(
            width: 300,
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                award['unlocked']
                    ? Image.asset(award['image'], height: 80)
                    : const Icon(Icons.lock, size: 60, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  award['title'],
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(
                  award['description'],
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Close"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int unlockedCount = awards.where((a) => a["unlocked"] == true).length;
    final double progress = unlockedCount / awards.length;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // HEADER + PROGRESS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "My Achievements ($unlockedCount/${awards.length})",
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF58C56E),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 10,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.green.shade400,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // GRID
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: GridView.builder(
                  itemCount: awards.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.85,
                  ),
                  itemBuilder: (context, index) {
                    final award = awards[index];
                    final bool unlocked = award['unlocked'];

                    return GestureDetector(
                      onTap: () => _showAwardPopup(context, award),
                      child: Container(
                        decoration: BoxDecoration(
                          color: unlocked
                              ? Colors.green.shade400
                              : Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // DARKENED IMAGE WHEN LOCKED
                            Opacity(
                              opacity: unlocked ? 1 : 0.35,
                              child: Image.asset(
                                award['image'],
                                height: 55,
                              ),
                            ),

                            // CENTER LOCK (ONLY IF LOCKED)
                            if (!unlocked)
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.3),
                                  shape: BoxShape.circle,
                                ),
                                padding: const EdgeInsets.all(8),
                                child: const Icon(
                                  Icons.lock,
                                  size: 28,
                                  color: Colors.white,
                                ),
                              ),

                            // TITLE (BOTTOM)
                            Positioned(
                              bottom: 6,
                              left: 6,
                              right: 6,
                              child: Text(
                                award['title'],
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
