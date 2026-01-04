import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

class SignSprintGame extends StatefulWidget {
  const SignSprintGame({super.key});

  @override
  State<SignSprintGame> createState() => _SignSprintGameState();
}

class _SignSprintGameState extends State<SignSprintGame> {
  // --- GAME CONFIGURATION ---
  final Color primaryColor = const Color(0xFF58C56E);
  final List<String> alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ".split("");

  // --- STATE VARIABLES ---
  int score = 0;
  int lives = 3;
  int timerSeconds = 10;
  int maxTime = 10;
  Timer? _timer;
  bool isGameOver = false;
  bool isHighLoading = false;

  // --- UI STATE ---
  String bearState = 'running';
  Color screenFlashColor = Colors.transparent;
  bool showSpeedUpLabel = false;
  int streak = 0;

  // --- NEW: COUNTDOWN STATE ---
  bool isGameStarting = true; // Blocks game interactions
  int startCountdown = 3; // The 3-2-1 countdown value

  late String currentLetter;
  late List<String> options;

  int? selectedButtonIndex;
  bool? wasSelectionCorrect;

  @override
  void initState() {
    super.initState();
    // Don't start game immediately. Start the 3-2-1 countdown.
    _startOpeningCountdown();
  }

  // --- NEW FEATURE: 3-2-1 COUNTDOWN ---
  void _startOpeningCountdown() {
    setState(() {
      isGameStarting = true;
      bearState = 'running';
    });

    // Initialize dummy data so the screen isn't empty behind the countdown
    currentLetter = "A";
    options = ["A", "B", "C", "D"];

    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (startCountdown > 1) {
          startCountdown--;
          HapticFeedback.selectionClick(); // Nice tick feel
        } else {
          timer.cancel();
          isGameStarting = false;
          _generateNewQuestion(); // START THE REAL GAME
        }
      });
    });
  }

  // --- NEW FEATURE: PAUSE & EXIT DIALOG ---
  Future<bool> _onWillPop() async {
    // Pause the game timer while dialog is open
    _timer?.cancel();

    final shouldPop = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Quit Game?"),
        content: const Text("Your progress will be lost."),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () {
              // Resume game if they stay
              Navigator.of(context).pop(false);
              if (!isGameOver && !isGameStarting) _startTimer();
            },
            child: const Text("Keep Playing"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text("Quit", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    return shouldPop ?? false;
  }

  void _startTimer() {
    _timer?.cancel();
    // Calculate difficulty
    int dynamicTime = (10 - (score ~/ 100)).clamp(3, 10);

    setState(() {
      maxTime = dynamicTime;
      timerSeconds = dynamicTime;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (mounted) {
        setState(() {
          if (timerSeconds > 0) {
            timerSeconds--;
          } else {
            _handleWrongAnswer(isTimeout: true);
          }
        });
      }
    });
  }

  void _generateNewQuestion() {
    if (lives <= 0) return;

    setState(() {
      selectedButtonIndex = null;
      wasSelectionCorrect = null;
      screenFlashColor = Colors.transparent;
    });

    currentLetter = alphabet[Random().nextInt(alphabet.length)];
    options = [currentLetter];

    while (options.length < 4) {
      String randomLetter = alphabet[Random().nextInt(alphabet.length)];
      if (!options.contains(randomLetter)) {
        options.add(randomLetter);
      }
    }
    options.shuffle();
    _startTimer();
  }

  void _triggerSpeedUpAlert() {
    setState(() => showSpeedUpLabel = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => showSpeedUpLabel = false);
    });
  }

  void _handleAnswer(String selected, int index) {
    // Prevent clicking during countdown or game over
    if (isGameOver || isGameStarting || selectedButtonIndex != null) return;

    setState(() {
      selectedButtonIndex = index;
    });

    if (selected == currentLetter) {
      HapticFeedback.lightImpact();
      setState(() {
        score += 10;
        streak++;
        bearState = 'correct';
        wasSelectionCorrect = true;
        screenFlashColor = Colors.green.withValues(alpha: 0.1);
      });

      if (score > 0 && score % 100 == 0) _triggerSpeedUpAlert();

      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted && !isGameOver) {
          setState(() => bearState = 'running');
          _generateNewQuestion();
        }
      });
    } else {
      _handleWrongAnswer(isTimeout: false);
    }
  }

  void _handleWrongAnswer({bool isTimeout = false}) {
    _timer?.cancel();
    HapticFeedback.heavyImpact();

    setState(() {
      lives--;
      streak = 0;
      bearState = 'wrong';
      if (!isTimeout) wasSelectionCorrect = false;
      screenFlashColor = Colors.red.withValues(alpha: 0.15);
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted && lives > 0) {
        setState(() => bearState = 'running');
        if (mounted && !isGameOver) _generateNewQuestion();
      }
    });

    if (lives <= 0) {
      Future.delayed(const Duration(milliseconds: 500), () {
        _endGame();
      });
    }
  }

  Future<void> _endGame() async {
    _timer?.cancel();
    setState(() {
      isGameOver = true;
      isHighLoading = true;
      screenFlashColor = Colors.transparent;
    });

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        final userDoc = FirebaseFirestore.instance.collection('users').doc(uid);
        final doc = await userDoc.get();
        int currentHighScore = doc.data()?['gameHighScore'] ?? 0;

        if (score > currentHighScore) {
          await userDoc.update({'gameHighScore': score});
        }
      }
    } catch (e) {
      debugPrint("Error saving score: $e");
    } finally {
      if (mounted) setState(() => isHighLoading = false);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // UPDATED: Using PopScope instead of WillPopScope
    return PopScope(
      canPop: false, // 1. Block the automatic back navigation
      onPopInvoked: (didPop) async {
        if (didPop) return; // If already popped, do nothing

        // 2. Show our dialog manually
        final shouldQuit = await _onWillPop();

        // 3. If user said "Yes" (true), manually close the screen
        if (shouldQuit && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text("Sign Sprint",
              style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () async {
              // Trigger the same exit logic as physical back button
              final shouldQuit = await _onWillPop();
              if (shouldQuit && context.mounted) {
                Navigator.of(context).pop();
              }
            },
          ),
        ),
        body: Stack(
          children: [
            isGameOver ? _buildGameOverScreen() : _buildGameplayScreen(),

            IgnorePointer(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                color: screenFlashColor,
              ),
            ),

            // Speed Up Alert
            Positioned(
              top: 100,
              left: 0,
              right: 0,
              child: IgnorePointer(
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: showSpeedUpLabel ? 1.0 : 0.0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 4))
                          ]),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.flash_on, color: Colors.white),
                          SizedBox(width: 8),
                          Text("SPEED UP!",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // --- COUNTDOWN OVERLAY ---
            if (isGameStarting)
              Container(
                color: Colors.black.withValues(alpha: 0.7),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "GET READY",
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2),
                      ),
                      const SizedBox(height: 20),
                      // Animated Countdown Text
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 400),
                        transitionBuilder: (child, anim) => ScaleTransition(
                            scale: anim,
                            child: FadeTransition(opacity: anim, child: child)),
                        child: Text(
                          "$startCountdown",
                          key: ValueKey<int>(startCountdown),
                          style: TextStyle(
                              fontSize: 100,
                              fontWeight: FontWeight.bold,
                              color: primaryColor),
                        ),
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

  Widget _buildGameplayScreen() {
    return SafeArea(
      child: Column(
        children: [
          // --- TOP BAR ---
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            color: const Color(0xFFF5F7FA),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Lives + Streak
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                        children: List.generate(
                            3,
                            (index) => Icon(
                                index < lives
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: Colors.red,
                                size: 24))),
                    if (streak > 1)
                      Text("🔥 $streak",
                          style: const TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                              fontSize: 12))
                  ],
                ),

                // Timer Ring
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 45,
                      height: 45,
                      child: CircularProgressIndicator(
                        value: timerSeconds / maxTime,
                        strokeWidth: 4,
                        backgroundColor: Colors.grey.shade300,
                        valueColor: AlwaysStoppedAnimation<Color>(
                            timerSeconds <= 3 ? Colors.red : primaryColor),
                      ),
                    ),
                    Text("$timerSeconds",
                        style: TextStyle(
                            color:
                                timerSeconds <= 3 ? Colors.red : Colors.black87,
                            fontWeight: FontWeight.bold,
                            fontSize: 18)),
                  ],
                ),

                // Score
                Text("Score: $score",
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          ),

          const Spacer(),

          // --- QUESTION CARD ---
          Column(
            children: [
              const Text("Match the Sign!",
                  style: TextStyle(color: Colors.grey, fontSize: 16)),
              const SizedBox(height: 10),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return ScaleTransition(scale: animation, child: child);
                },
                child: Container(
                  key: ValueKey<String>(currentLetter),
                  height: 220,
                  width: 220,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: primaryColor.withValues(alpha: 0.3), width: 2),
                    boxShadow: [
                      BoxShadow(
                          color: primaryColor.withValues(alpha: 0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10))
                    ],
                  ),
                  child: Image.asset(
                    'assets/images/dictionary/${currentLetter.toLowerCase()}.jpg',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Center(
                        child: Icon(Icons.broken_image,
                            size: 50, color: Colors.grey)),
                  ),
                ),
              ),
            ],
          ),

          const Spacer(),

          // --- MASCOT ---
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Image.asset(
                    key: ValueKey<String>(bearState),
                    bearState == 'correct'
                        ? 'assets/images/games/correct.png'
                        : bearState == 'wrong'
                            ? 'assets/images/games/wrong.png'
                            : 'assets/images/games/running.png',
                    height: 60,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  bearState == 'correct'
                      ? "Awesome! Great job!"
                      : bearState == 'wrong'
                          ? "Oh no! Try again!"
                          : "Quick! Pick the letter!",
                  style: const TextStyle(
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),

          // --- OPTIONS GRID ---
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFFF5F7FA),
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 2.2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
              ),
              itemCount: 4,
              itemBuilder: (context, index) {
                Color btnColor = Colors.white;
                Color txtColor = primaryColor;
                if (selectedButtonIndex == index) {
                  if (wasSelectionCorrect == true) {
                    btnColor = Colors.green;
                    txtColor = Colors.white;
                  } else if (wasSelectionCorrect == false) {
                    btnColor = Colors.red;
                    txtColor = Colors.white;
                  }
                }

                return ElevatedButton(
                  // 3. DISABLE BUTTONS DURING COUNTDOWN
                  onPressed: isGameStarting
                      ? null
                      : () => _handleAnswer(options[index], index),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: btnColor,
                    foregroundColor: txtColor,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                      side: BorderSide(
                          color: selectedButtonIndex == index
                              ? Colors.transparent
                              : primaryColor,
                          width: 2),
                    ),
                  ),
                  child: Text(
                    options[index],
                    style: const TextStyle(
                        fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameOverScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/games/game_over.png', height: 180),
            const SizedBox(height: 30),
            const Text("GAME OVER",
                style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent,
                    letterSpacing: 1.5)),
            const SizedBox(height: 10),
            Text("Final Score: $score",
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.w500)),
            const SizedBox(height: 40),
            if (isHighLoading)
              const CircularProgressIndicator()
            else
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        side: BorderSide(color: primaryColor, width: 2),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text("Exit",
                          style: TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          score = 0;
                          lives = 3;
                          timerSeconds = 10;
                          streak = 0;
                          isGameOver = false;
                          bearState = 'running';
                          screenFlashColor = Colors.transparent;
                          startCountdown = 3; // Reset countdown
                          // Restart with countdown
                          _startOpeningCountdown();
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("Play Again",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              )
          ],
        ),
      ),
    );
  }
}
