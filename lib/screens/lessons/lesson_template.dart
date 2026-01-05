import 'dart:math';
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart' as yt;
import 'package:confetti/confetti.dart';
import '../../models/lesson_content.dart';

// Assumed Widget Imports
import '../../widgets/lesson_button.dart';
import '../../widgets/lesson_close.dart';
import '../../widgets/lesson_back.dart';
import '../../widgets/progress_bar.dart';

class LessonTemplate extends StatefulWidget {
  final String lessonTitle;
  final String heroImage;
  final List<LessonContent> contents;
  final VoidCallback? onComplete;

  const LessonTemplate({
    super.key,
    required this.lessonTitle,
    required this.heroImage,
    required this.contents,
    this.onComplete,
  });

  @override
  State<LessonTemplate> createState() => _LessonTemplateState();
}

class _LessonTemplateState extends State<LessonTemplate> {
  final PageController _controller = PageController();
  late ConfettiController _confettiController;

  int _currentIndex = 0;
  static const Color primaryGreen = Color(0xFF58C56E);
  static const Color errorRed = Color(0xFFFF6B6B);

  // --- QUIZ STATE ---
  String? _selectedQuizAnswer;
  bool? _isQuizCorrect;

  // CHANGED: Now a list of questions instead of a single one
  List<LessonContent> _quizQuestions = [];
  late List<String> _quizOptions;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
    _generateQuiz();
  }

  // --- DYNAMIC QUIZ GENERATOR (UPDATED) ---
  void _generateQuiz() {
    if (widget.contents.isNotEmpty) {
      // 1. Create a copy of contents and shuffle them to randomize order
      final shuffled = List<LessonContent>.from(widget.contents)..shuffle();

      // 2. Take up to 3 items (or fewer if the lesson has less than 3)
      final count = min(3, shuffled.length);
      _quizQuestions = shuffled.sublist(0, count);

      // 3. Get all titles as options (e.g., A, B, C, D...)
      _quizOptions = widget.contents.map((e) => e.title).toList();
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  // Calculate total slides: Intro + (Learning Slides) + Practice + (Quiz Questions) + Completion
  int get totalSlides => 2 + widget.contents.length + _quizQuestions.length + 1;

  double get _progress => (_currentIndex / (totalSlides - 1)).clamp(0.0, 1.0);

  void _nextPage() {
    if (_currentIndex < totalSlides - 1) {
      _controller.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);

      setState(() {
        _currentIndex++;
        // RESET QUIZ STATE FOR THE NEXT SLIDE
        _selectedQuizAnswer = null;
        _isQuizCorrect = null;
      });

      if (_currentIndex == totalSlides - 1) {
        _confettiController.play();
      }
    }
  }

  void _prevPage() {
    if (_currentIndex > 0) {
      _controller.previousPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);

      setState(() {
        _currentIndex--;
        // Reset quiz state when going back too, just in case
        _selectedQuizAnswer = null;
        _isQuizCorrect = null;
      });
    }
  }

  void _exitLesson() => Navigator.pop(context);

  // CHANGED: Now accepts the 'correctAnswer' for the specific slide being viewed
  void _checkAnswer(String selectedAnswer, String correctAnswer) async {
    setState(() {
      _selectedQuizAnswer = selectedAnswer;
    });

    if (selectedAnswer == correctAnswer) {
      setState(() => _isQuizCorrect = true);
      await Future.delayed(const Duration(seconds: 1));
      _nextPage();
    } else {
      setState(() => _isQuizCorrect = false);
      await Future.delayed(const Duration(seconds: 1));
      setState(() {
        _selectedQuizAnswer = null;
        _isQuizCorrect = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.contents.isEmpty) {
      return const Scaffold(body: Center(child: Text("No content")));
    }

    final topPadding = MediaQuery.of(context).size.height * 0.06;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            PageView(
              controller: _controller,
              physics: const NeverScrollableScrollPhysics(),
              children: _buildSlides(),
            ),
            ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                primaryGreen,
                Colors.blue,
                Colors.orange,
                Colors.pink
              ],
              numberOfParticles: 50,
              gravity: 0.3,
            ),
            Positioned(
              top: topPadding,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    if (_currentIndex > 0)
                      LessonBackButton(onPressed: _prevPage)
                    else
                      const SizedBox(width: 48),
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

    // 1. Learning Slides
    slides.addAll(widget.contents.map((data) => _buildLetterSlide(data)));

    // 2. Practice Slide
    slides.add(_buildPracticeSlide());

    // 3. Quiz Slides (One for each generated question)
    for (int i = 0; i < _quizQuestions.length; i++) {
      slides.add(_buildQuizSlide(_quizQuestions[i], i));
    }

    // 4. Completion Slide
    slides.add(_buildCompletionSlide());

    return slides;
  }

  Widget _buildIntroSlide() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 120, 24, 24),
      child: Column(
        children: [
          Text(widget.lessonTitle,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey)),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: primaryGreen.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Image.asset(
              widget.heroImage,
              height: 200,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.image_not_supported,
                  size: 100,
                  color: Colors.grey),
            ),
          ),
          const SizedBox(height: 32),
          Text("Welcome to ${widget.lessonTitle}!",
              textAlign: TextAlign.center,
              style:
                  const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          const Text("Go at your own pace — tap Start when you’re ready!",
              textAlign: TextAlign.center,
              style:
                  TextStyle(fontSize: 16, height: 1.5, color: Colors.black87)),
          const SizedBox(height: 40),
          LessonButton(
              label: "Start", onPressed: _nextPage, color: primaryGreen),
        ],
      ),
    );
  }

  Widget _buildLetterSlide(LessonContent data) {
    yt.YoutubePlayerController controller = yt.YoutubePlayerController(
      initialVideoId: data.videoId,
      flags: const yt.YoutubePlayerFlags(autoPlay: false, mute: false),
    );
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 120, 24, 24),
      child: Column(
        children: [
          Text(data.title,
              style:
                  const TextStyle(fontSize: 72, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          yt.YoutubePlayer(
              controller: controller, progressIndicatorColor: primaryGreen),
          const SizedBox(height: 24),
          Column(
              children: data.steps
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

  Widget _buildPracticeSlide() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 120, 24, 24),
      child: Column(
        children: [
          const Text("Review",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text("Try signing them yourself!",
              style: TextStyle(color: Colors.grey, fontSize: 16)),
          const SizedBox(height: 32),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: widget.contents.map((data) {
                return Container(
                  width: 140,
                  height: 190,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade200, width: 2),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4))
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(data.title,
                          style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: primaryGreen)),
                      const SizedBox(height: 8),
                      Expanded(
                          child: Image.asset(data.imagePath,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => const Icon(
                                  Icons.broken_image,
                                  color: Colors.grey))),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(20)),
                        child: Text(data.word,
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[700])),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 40),
          LessonButton(
              label: "Start Quiz", onPressed: _nextPage, color: primaryGreen),
        ],
      ),
    );
  }

  // CHANGED: Now takes specific question data and index
  Widget _buildQuizSlide(LessonContent questionData, int index) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 120, 24, 24),
      child: Column(
        children: [
          Text("Quiz Time (${index + 1}/${_quizQuestions.length})",
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey)),
          const SizedBox(height: 16),
          const Text("What letter is this?",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),
          Container(
            height: 220,
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4))
              ],
            ),
            child: Image.asset(questionData.imagePath, fit: BoxFit.contain),
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("This is ", style: TextStyle(fontSize: 20)),
              Container(
                width: 60,
                height: 60,
                alignment: Alignment.center,
                decoration: BoxDecoration(
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
                child: Text(_selectedQuizAnswer ?? "?",
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: _selectedQuizAnswer == null
                            ? Colors.grey.shade300
                            : Colors.white)),
              ),
            ],
          ),
          const SizedBox(height: 40),
          Wrap(
            spacing: 20,
            children: _quizOptions.map((option) {
              return GestureDetector(
                // CHANGED: Pass the current question's correct answer
                onTap: () => _checkAnswer(option, questionData.title),
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
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 5,
                          offset: const Offset(0, 4))
                    ],
                  ),
                  child: Text(option,
                      style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87)),
                ),
              );
            }).toList(),
          ),
          if (_isQuizCorrect == false)
            const Padding(
                padding: EdgeInsets.only(top: 20),
                child: Text("Oops! Try again.",
                    style: TextStyle(
                        color: errorRed, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget _buildCompletionSlide() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 120, 24, 24),
      child: Column(children: [
        const Text("Lesson Complete!",
            style: TextStyle(fontSize: 18, color: Colors.grey)),
        const SizedBox(height: 16),
        Image.asset('assets/images/celebration.png',
            height: 150,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) =>
                const Icon(Icons.check_circle, size: 120, color: primaryGreen)),
        const SizedBox(height: 24),
        Text("You’ve completed ${widget.lessonTitle}!",
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 32),
        LessonButton(
            label: "Finish",
            onPressed: () {
              if (widget.onComplete != null) {
                widget.onComplete!();
              }
              Navigator.pop(context);
            },
            color: primaryGreen),
      ]),
    );
  }
}
