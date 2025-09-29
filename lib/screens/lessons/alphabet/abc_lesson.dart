import 'package:flutter/material.dart';
import 'package:hearing_hands/widgets/progress_bar.dart';
import 'package:hearing_hands/widgets/lesson_button.dart';
import 'package:hearing_hands/widgets/lesson_close.dart';
import 'package:hearing_hands/widgets/lesson_back.dart';

class ABCLesson extends StatefulWidget {
  const ABCLesson({super.key});

  @override
  State<ABCLesson> createState() => _ABCLessonState();
}

class _ABCLessonState extends State<ABCLesson> {
  final PageController _controller = PageController();
  int _currentIndex = 0;

  final int totalSlides = 7;

  void _nextPage() {
    if (_currentIndex < totalSlides - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentIndex++);
    }
  }

  void _prevPage() {
    if (_currentIndex > 0) {
      _controller.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentIndex--);
    }
  }

  void _exitLesson() {
    Navigator.pop(context);
  }

  double get _progress {
    final List<double> progressValues = [
      0.0,
      0.16,
      0.32,
      0.48,
      0.64,
      0.80,
      1.0
    ];
    return (_currentIndex >= 0 && _currentIndex < progressValues.length)
        ? progressValues[_currentIndex]
        : 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            PageView(
              controller: _controller,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildIntroSlide(),
                _buildLetterSlide(
                    "A", "https://youtube.com/example-a", "Apple 🍎"),
                _buildLetterSlide(
                    "B", "https://youtube.com/example-b", "Ball 🏀"),
                _buildLetterSlide(
                    "C", "https://youtube.com/example-c", "Cat 🐱"),
                _buildPracticeSlide(),
                _buildQuizSlide(),
                _buildCompletionSlide(),
              ],
            ),
            Positioned(
              top: 16,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 36,
                      child: _currentIndex > 0
                          ? LessonBackButton(onPressed: _prevPage)
                          : const SizedBox(),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: (_currentIndex < totalSlides - 1)
                          ? ProgressBar(progress: _progress)
                          : const SizedBox(),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 36,
                      child: LessonCloseButton(onPressed: _exitLesson),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIntroSlide() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 72, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Lesson 1: ABC",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Image.asset(
              'assets/images/abclesson.png',
              height: 180,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Welcome to Your First Lesson!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "We’ll learn how to sign A, B, and C together.\n\n💡 Go at your own pace — tap Start when you’re ready!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),
                LessonButton(label: "Start", onPressed: _nextPage),
              ],
            ),
          ),
        ],
      ),
    );
  }

// Letter Slides
  Widget _buildLetterSlide(String letter, String videoUrl, String exampleWord) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 72, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Lesson 1: ABC",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  letter,
                  style: const TextStyle(
                      fontSize: 72, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(child: Text("📹 Video for $letter")),
                ),
                const SizedBox(height: 16),
                Text(
                  "Let’s learn how to sign the letter $letter.",
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  "$letter is for $exampleWord — think of this word when you sign it!",
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                LessonButton(label: "Next", onPressed: _nextPage),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Practice Slide
  Widget _buildPracticeSlide() {
    return _buildCenteredContent(
      title: "Practice",
      children: [
        const Text(
          "Practice Time! 🧠",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        const Text(
          "Which of these signs represents the letter B?",
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Container(
          height: 150,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(child: Text("🖼️ Image Choices Placeholder")),
        ),
        const SizedBox(height: 8),
        const Text(
          "🎯 Look closely at the hand shapes and take your best guess!",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 32),
        LessonButton(label: "Check Answer", onPressed: _nextPage),
      ],
    );
  }

  // Quiz Slide
  Widget _buildQuizSlide() {
    return _buildCenteredContent(
      title: "Mini Quiz",
      children: [
        const Text(
          "Mini Quiz Time! ✍️",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        const Text(
          "What letter do you think this sign shows?",
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Container(
          height: 150,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(child: Text("🎥 Video/Image Placeholder")),
        ),
        const SizedBox(height: 8),
        const Text(
          "🌟 Think back to the videos and practice slides.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 32),
        LessonButton(label: "Submit Quiz", onPressed: _nextPage),
      ],
    );
  }

  // Completion Slide
  Widget _buildCompletionSlide() {
    return _buildCenteredContent(
      title: "Great Job!",
      children: [
        const Text(
          "🎉 You’ve completed ABC!",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        const Text(
          "You now know how to sign A, B, and C.\n👏 That’s a big first step toward fluency.",
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        LessonButton(
          label: "Continue to Lesson 2",
          onPressed: () {},
        ),
      ],
    );
  }

  // New: Centralized layout with title
  Widget _buildCenteredContent({
    required String title,
    required List<Widget> children,
  }) {
    return Padding(
      padding:
          const EdgeInsets.fromLTRB(24, 72, 24, 24), // push down below top bar
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: children,
            ),
          ),
        ],
      ),
    );
  }
}
