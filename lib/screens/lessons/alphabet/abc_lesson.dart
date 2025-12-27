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

  final List<Map<String, String>> letters = [
    {"letter": "A", "word": "Apple 🍎", "video": "xqmKLCsDqsE"},
    {"letter": "B", "word": "Ball 🏀", "video": "LNwF7eA4Pcg"},
    {"letter": "C", "word": "Cat 🐱", "video": "9T8ZMxdu_rE"},
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
              physics: const ClampingScrollPhysics(),
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
                    LessonBackButton(onPressed: _prevPage),
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
    slides.addAll(letters.map((data) =>
        _buildLetterSlide(data['letter']!, data['video']!, data['word']!)));
    slides.add(_buildPracticeSlide());
    slides.add(_buildQuizSlide());
    slides.add(_buildCompletionSlide());
    return slides;
  }

  Widget _buildIntroSlide() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 120, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            "Lesson 1: ABC",
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          Image.asset('assets/images/abclesson.png',
              height: 180, fit: BoxFit.contain),
          const SizedBox(height: 32),
          const Text(
            "Welcome to Your First Lesson!",
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.black87),
          ),
          const SizedBox(height: 16),
          const Text(
            "We’ll learn how to sign A, B, and C together.\n\n💡 Go at your own pace — tap Start when you’re ready!",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, height: 1.5, color: Colors.black87),
          ),
          const SizedBox(height: 40),
          LessonButton(
              label: "Start", onPressed: _nextPage, color: primaryGreen),
        ],
      ),
    );
  }

  Widget _buildLetterSlide(String letter, String videoUrl, String exampleWord) {
    // Create YoutubePlayerController using the alias 'yt'
    yt.YoutubePlayerController controller = yt.YoutubePlayerController(
      initialVideoId: yt.YoutubePlayer.convertUrlToId(videoUrl)!,
      flags: const yt.YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
      ),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 120, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Letter title
          Text(letter,
              style: const TextStyle(
                  fontSize: 72,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87)),
          const SizedBox(height: 16),

          // YouTube video player
          yt.YoutubePlayer(
            controller: controller,
            showVideoProgressIndicator: true,
            progressIndicatorColor: Colors.green,
          ),

          const SizedBox(height: 16),

          // Example word text
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: const TextStyle(fontSize: 16, color: Colors.black87),
              children: [
                TextSpan(text: "$letter is for "),
                TextSpan(
                    text: exampleWord,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const TextSpan(text: " — practice this sign!"),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Next button
          LessonButton(
              label: "Next", onPressed: _nextPage, color: primaryGreen),
        ],
      ),
    );
  }

  Widget _buildPracticeSlide() {
    return _buildCenteredContent(
      title: "Practice",
      children: [
        const Text("Practice Time! 🧠",
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87)),
        const SizedBox(height: 16),
        const Text("Try copying the hand signs for A, B, and C.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black87)),
        const SizedBox(height: 32),
        LessonButton(label: "Next", onPressed: _nextPage, color: primaryGreen),
      ],
    );
  }

  Widget _buildQuizSlide() {
    return _buildCenteredContent(
      title: "Mini Quiz",
      children: [
        const Text("Quick Quiz ✍️",
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87)),
        const SizedBox(height: 16),
        const Text("Which letter is this?",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black87)),
        const SizedBox(height: 32),
        LessonButton(
            label: "Submit & Continue",
            onPressed: _nextPage,
            color: primaryGreen),
      ],
    );
  }

  Widget _buildCompletionSlide() {
    return _buildCenteredContent(
      title: "Lesson Complete!",
      children: [
        const Icon(Icons.check_circle, size: 100, color: primaryGreen),
        const SizedBox(height: 16),
        const Text("🎉 You’ve completed ABC!",
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87)),
        const SizedBox(height: 12),
        const Text("Great job learning A, B, and C!",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black87)),
        const SizedBox(height: 32),
        LessonButton(
            label: "Continue to Lesson 2",
            onPressed: () {
              Navigator.pop(context);
            },
            color: primaryGreen),
      ],
    );
  }

  Widget _buildCenteredContent(
      {required String title, required List<Widget> children}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 120, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey)),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}
