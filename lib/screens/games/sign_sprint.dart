import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  Timer? _timer;
  bool isGameOver = false;
  bool isHighLoading = false;

  // --- CURRENT QUESTION DATA ---
  late String currentLetter;
  late List<String> options;

  @override
  void initState() {
    super.initState();
    _generateNewQuestion();
  }

  // --- 1. DYNAMIC TIMER LOGIC ---
  void _startTimer() {
    _timer?.cancel();

    // LOGIC: Start at 10s. Every 20 points, reduce time by 1s.
    // .clamp(3, 10) ensures it never goes above 10s or below 3s.
    int dynamicTime = (10 - (score ~/ 20)).clamp(3, 10);

    setState(() {
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

  // --- 2. QUESTION GENERATION ---
  void _generateNewQuestion() {
    if (lives <= 0) return;

    // Pick 1 random correct letter
    currentLetter = alphabet[Random().nextInt(alphabet.length)];
    options = [currentLetter];

    // Pick 3 random WRONG letters
    while (options.length < 4) {
      String randomLetter = alphabet[Random().nextInt(alphabet.length)];
      if (!options.contains(randomLetter)) {
        options.add(randomLetter);
      }
    }
    options.shuffle(); // Mix them up
    _startTimer(); // Restart the clock
  }

  // --- 3. ANSWER CHECKING ---
  void _handleAnswer(String selected) {
    if (isGameOver) return;

    if (selected == currentLetter) {
      // CORRECT
      setState(() {
        score += 10;
      });

      // Show "Speed Up" warning every 20 points
      if (score > 0 && score % 20 == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("⚡ SPEED UP! The timer is getting faster!"),
            backgroundColor: Colors.orange,
            duration: Duration(milliseconds: 800),
          ),
        );
      }

      _generateNewQuestion();
    } else {
      // WRONG
      _handleWrongAnswer();
    }
  }

  void _handleWrongAnswer({bool isTimeout = false}) {
    _timer?.cancel();

    setState(() {
      lives--;
    });

    // Vibration/Feedback could go here
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isTimeout ? "⏰ Time's up! -1 ❤️" : "❌ Wrong! -1 ❤️"),
        backgroundColor: Colors.redAccent,
        duration: const Duration(milliseconds: 500),
      ),
    );

    if (lives <= 0) {
      _endGame();
    } else {
      // Give a small delay before next question so they realize they messed up
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted && !isGameOver) _generateNewQuestion();
      });
    }
  }

  // --- 4. GAME OVER & FIREBASE SAVE ---
  Future<void> _endGame() async {
    _timer?.cancel();
    setState(() {
      isGameOver = true;
      isHighLoading = true;
    });

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        final userDoc = FirebaseFirestore.instance.collection('users').doc(uid);
        final doc = await userDoc.get();

        // Check previous high score
        int currentHighScore = doc.data()?['gameHighScore'] ?? 0;

        if (score > currentHighScore) {
          // New High Score!
          await userDoc.update({'gameHighScore': score});
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("🏆 NEW HIGH SCORE SAVED!"),
                backgroundColor: Color(0xFF58C56E),
              ),
            );
          }
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

  // --- UI BUILDING ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Sign Sprint",
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        automaticallyImplyLeading:
            false, // User must click "Exit" button to leave
      ),
      body: isGameOver ? _buildGameOverScreen() : _buildGameplayScreen(),
    );
  }

  Widget _buildGameplayScreen() {
    return SafeArea(
      child: Column(
        children: [
          // --- TOP STATS BAR ---
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            color: const Color(0xFFF5F7FA),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Hearts
                Row(
                  children: List.generate(
                      3,
                      (index) => Icon(
                            index < lives
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: Colors.red,
                            size: 28,
                          )),
                ),
                // Timer (Turns Red if low)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: timerSeconds <= 3 ? Colors.red : primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    "$timerSeconds",
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                  ),
                ),
                // Score
                Text(
                  "Score: $score",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          const Spacer(),

          // --- QUESTION CARD ---
          Column(
            children: [
              const Text(
                "Match the Sign!",
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
              const SizedBox(height: 10),
              Container(
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
                      offset: const Offset(0, 10),
                    )
                  ],
                ),
                child: Image.asset(
                  // Logic to find the correct image
                  'assets/images/dictionary/${currentLetter.toLowerCase()}.jpg',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Center(
                      child: Icon(Icons.broken_image,
                          size: 50, color: Colors.grey)),
                ),
              ),
            ],
          ),

          const Spacer(),

          // --- MASCOT HELPER ---
          // A small touch to make it feel familiar
          if (!isGameOver)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/images/talkbearr.png', height: 40),
                  const SizedBox(width: 10),
                  const Text("Quick! Pick the letter!",
                      style: TextStyle(
                          color: Colors.grey, fontStyle: FontStyle.italic)),
                ],
              ),
            ),

          // --- OPTIONS GRID ---
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFFF5F7FA), // The color itself is a constant
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
                return ElevatedButton(
                  onPressed: () => _handleAnswer(options[index]),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: primaryColor,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                      side: BorderSide(color: primaryColor, width: 2),
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
            // Mascot
            Image.asset('assets/images/groupbear.png', height: 160),

            const SizedBox(height: 30),

            const Text(
              "GAME OVER",
              style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent,
                  letterSpacing: 1.5),
            ),

            const SizedBox(height: 10),

            Text(
              "Final Score: $score",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
            ),

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
                          isGameOver = false;
                          _generateNewQuestion();
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
