import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart' as yt;
import 'package:hearing_hands/widgets/lesson_button.dart';
import 'package:hearing_hands/widgets/lesson_close.dart';
import 'package:hearing_hands/widgets/lesson_back.dart';
import 'package:hearing_hands/widgets/progress_bar.dart';

class ABCLesson extends StatefulWidget {
  const ABCLesson({super.key});

  @override
  State<ABCLesson> createState() => _ABCLessonState();
}

class _ABCLessonState extends State<ABCLesson> {
  final PageController _controller = PageController();
  int _currentIndex = 0;
  static const Color primaryGreen = Color(0xFF58C56E);
  static const Color errorRed = Color(0xFFFF6B6B);

  // --- QUIZ STATE ---
  // We track what the user tapped and if it was right
  String? _selectedQuizAnswer;
  bool? _isQuizCorrect;

  final List<Map<String, dynamic>> letters = [
    {
      "letter": "A",
      "word": "Apple 🍎",
      "video": "xqmKLCsDqsE",
      "steps": [
        "Make a closed fist.",
        "Thumb on side of index finger.",
        "Face palm forward."
      ]
    },
    {
      "letter": "B",
      "word": "Ball 🏀",
      "video": "LNwF7eA4Pcg",
      "steps": [
        "Fingers up and together.",
        "Thumb across palm.",
        "Face hand forward."
      ]
    },
    {
      "letter": "C",
      "word": "Cat 🐱",
      "video": "9T8ZMxdu_rE",
      "steps": [
        "Curve fingers into C shape.",
        "Keep hand relaxed.",
        "Face slightly forward."
      ]
    },
  ];

  int get totalSlides => 4 + letters.length;
  double get _progress => (_currentIndex / (totalSlides - 1)).clamp(0.0, 1.0);

  void _nextPage() {
    if (_currentIndex < totalSlides - 1) {
      _controller.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      setState(() => _currentIndex++);
    }
  }

  void _prevPage() {
    if (_currentIndex > 0) {
      _controller.previousPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      setState(() => _currentIndex--);
    }
  }

  void _exitLesson() => Navigator.pop(context);

  // --- QUIZ LOGIC ---
  void _checkAnswer(String answer) async {
    setState(() {
      _selectedQuizAnswer = answer;
    });

    // Hardcoded correct answer for this demo is 'B'
    // In a real app, you would pass the question data dynamically
    String correctAnswer = "B";

    if (answer == correctAnswer) {
      setState(() => _isQuizCorrect = true);
      // Wait 1 second so they see the Green success color, then move on
      await Future.delayed(const Duration(seconds: 1));
      _nextPage();
    } else {
      setState(() => _isQuizCorrect = false);
      // Wait 1 second so they see Red, then reset so they can try again
      await Future.delayed(const Duration(seconds: 1));
      setState(() {
        _selectedQuizAnswer = null;
        _isQuizCorrect = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).size.height * 0.06;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            PageView(
              controller: _controller,
              physics:
                  const NeverScrollableScrollPhysics(), // Disable Swipe so they MUST use buttons
              children: _buildSlides(),
            ),
            Positioned(
              top: topPadding,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Hide Back button on first slide or during quiz success
                    if (_currentIndex > 0)
                      LessonBackButton(onPressed: _prevPage)
                    else
                      const SizedBox(
                          width: 48), // Spacer to keep layout balanced

                    const SizedBox(width: 12),
                    Expanded(child: ProgressBar(progress: _progress)),
                    const SizedBox(width: 12),
                    LessonCloseButton(onPressed: _exitLesson),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildSlides() {
    List<Widget> slides = [_buildIntroSlide()];

    slides.addAll(letters.map((data) => _buildLetterSlide(
          data['letter']!,
          data['video']!,
          List<String>.from(data['steps']!),
          data['word']!,
        )));

    slides.add(_buildPracticeSlide());
    slides.add(_buildQuizSlide());
    slides.add(_buildCompletionSlide());

    return slides;
  }

  // ... (Keep _buildIntroSlide and _buildLetterSlide exactly as you had them) ...
  // Paste them here if you need me to repeat them, but I assume they are good!

  // --- REUSED YOUR INTRO & LETTER CODE FOR CONTEXT ---
  Widget _buildIntroSlide() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 120, 24, 24),
      child: Column(
        children: [
          const Text("Lesson 1: ABC",
              style: TextStyle(fontSize: 18, color: Colors.grey)),
          const SizedBox(height: 16),
          // Placeholder icon if image is missing
          const Icon(Icons.school_rounded, size: 100, color: primaryGreen),
          const SizedBox(height: 32),
          const Text("Welcome!",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          const Text("We’ll learn A, B, and C.\nTap Start when ready!",
              textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
          const SizedBox(height: 40),
          LessonButton(
              label: "Start", onPressed: _nextPage, color: primaryGreen),
        ],
      ),
    );
  }

  Widget _buildLetterSlide(
      String letter, String videoUrl, List<String> steps, String word) {
    // ... Your existing code for this widget is perfect ...
    yt.YoutubePlayerController controller = yt.YoutubePlayerController(
      initialVideoId: videoUrl,
      flags: const yt.YoutubePlayerFlags(autoPlay: false, mute: false),
    );
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 120, 24, 24),
      child: Column(
        children: [
          Text(letter,
              style:
                  const TextStyle(fontSize: 72, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          yt.YoutubePlayer(
              controller: controller, progressIndicatorColor: primaryGreen),
          const SizedBox(height: 24),
          // ... steps list ...
          Column(
              children: steps
                  .map(
                      (s) => Text("• $s", style: const TextStyle(fontSize: 16)))
                  .toList()),
          const SizedBox(height: 32),
          LessonButton(
              label: "Next", onPressed: _nextPage, color: primaryGreen),
        ],
      ),
    );
  }

  // --- NEW: PRACTICE SLIDE (The "Cheat Sheet") ---
  Widget _buildPracticeSlide() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 120, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            "Review",
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87),
          ),
          const SizedBox(height: 8),
          const Text(
            "Here are the 3 signs you just learned.\nTry signing them yourself!",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
          const SizedBox(height: 32),

          // Horizontal list of "Cards"
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: letters.map((data) {
                return Container(
                  width: 140,
                  height: 180,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade200, width: 2),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4))
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(data['letter'],
                          style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: primaryGreen)),
                      const SizedBox(height: 10),
                      // In real app, put Image.asset here. Using Icon for now.
                      const Icon(Icons.pan_tool_rounded,
                          size: 50, color: Colors.black54),
                      const SizedBox(height: 10),
                      Text(data['word'].split(' ')[0],
                          style: const TextStyle(
                              fontSize: 14, color: Colors.grey)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 40),
          LessonButton(
              label: "I'm Ready for the Quiz!",
              onPressed: _nextPage,
              color: primaryGreen),
        ],
      ),
    );
  }

  // --- NEW: QUIZ SLIDE (Duolingo Style) ---
  Widget _buildQuizSlide() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 120, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            "Quiz Time",
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          const Text(
            "What letter is this?",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 30),

          // 1. The Question Image (Hand Sign B)
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Center(
              // TODO: Replace with Image.asset('assets/images/sign_b.png')
              child: Icon(Icons.back_hand_rounded,
                  size: 100, color: Colors.black87),
            ),
          ),

          const SizedBox(height: 30),

          // 2. The "Fill in the Blank" Puzzle
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("This is the letter ", style: TextStyle(fontSize: 20)),
              Container(
                width: 60,
                height: 60,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  // Dynamic Color Logic
                  color: _isQuizCorrect == true
                      ? primaryGreen
                      : (_isQuizCorrect == false ? errorRed : Colors.white),
                  border: Border.all(
                      color: _isQuizCorrect == null
                          ? Colors.grey.shade300
                          : Colors.transparent,
                      width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _selectedQuizAnswer ?? "?",
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: _selectedQuizAnswer == null
                          ? Colors.grey.shade300
                          : Colors.white),
                ),
              ),
            ],
          ),

          const SizedBox(height: 40),

          // 3. The Options (Bubbles)
          Wrap(
            spacing: 20,
            children: ["A", "B", "C"].map((option) {
              return GestureDetector(
                onTap: () => _checkAnswer(option),
                child: Container(
                  width: 80,
                  height: 80,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.grey.shade300, width: 2),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 5,
                          offset: const Offset(0, 4))
                    ],
                  ),
                  child: Text(
                    option,
                    style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87),
                  ),
                ),
              );
            }).toList(),
          ),

          if (_isQuizCorrect == false)
            const Padding(
              padding: EdgeInsets.only(top: 20),
              child: Text("Oops! Try again.",
                  style:
                      TextStyle(color: errorRed, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
    );
  }

  // ... (Keep _buildCompletionSlide and _buildCenteredContent exactly as you had them) ...
  Widget _buildCompletionSlide() {
    return _buildCenteredContent(
      title: "Lesson Complete!",
      children: [
        const Icon(Icons.check_circle, size: 100, color: primaryGreen),
        const SizedBox(height: 16),
        const Text("🎉 You’ve completed ABC!",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        const Text("Great job learning A, B, and C!",
            textAlign: TextAlign.center),
        const SizedBox(height: 32),
        LessonButton(
            label: "Finish",
            onPressed: () => Navigator.pop(context),
            color: primaryGreen),
      ],
    );
  }

  Widget _buildCenteredContent(
      {required String title, required List<Widget> children}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 120, 24, 24),
      child: Column(children: [
        Text(title, style: const TextStyle(fontSize: 18, color: Colors.grey)),
        const SizedBox(height: 16),
        ...children
      ]),
    );
  }
}
