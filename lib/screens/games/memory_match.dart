import 'dart:async';
import 'dart:math'; // Required for the 3D flip animation
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/services.dart';

class MemoryMatchGame extends StatefulWidget {
  const MemoryMatchGame({super.key});

  @override
  State<MemoryMatchGame> createState() => _MemoryMatchGameState();
}

class _MemoryMatchGameState extends State<MemoryMatchGame> {
  // --- CONFIGURATION ---
  final Color primaryColor = const Color(0xFF58C56E);

  // --- GAME STATE ---
  List<String> _gameBoard = [];
  List<bool> _cardFlipped = [];
  List<bool> _cardMatched = [];
  int? _previousIndex;
  bool _isProcessing = false;
  int _moves = 0;

  // --- UI STATE ---
  bool _isPeeking = true;
  int _peekCountdown = 3;
  bool isGameOver = false;
  String bearState = 'neutral';
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
    _startNewGame();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  // --- 1. SETUP LOGIC (20 Cards) ---
  void _startNewGame() {
    setState(() {
      // 10 pairs = 20 Cards
      List<String> letters = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j'];
      _gameBoard = [...letters, ...letters];
      _gameBoard.shuffle();

      // Reset lists
      _cardFlipped = List.generate(20, (index) => true);
      _cardMatched = List.generate(20, (index) => false);

      _previousIndex = null;
      _isProcessing = true;
      _moves = 0;
      _isPeeking = true;
      _peekCountdown = 3;
      isGameOver = false;
      bearState = 'neutral';
    });

    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_peekCountdown > 0) {
          _peekCountdown--;
        } else {
          timer.cancel();
          // Hide all cards
          _cardFlipped = List.generate(20, (index) => false);
          _isPeeking = false;
          _isProcessing = false;
        }
      });
    });
  }

  // --- 2. TAP INTERACTION ---
  void _onCardTap(int index) {
    // FIXED: Added curly braces {} to satisfy the linter
    if (_isProcessing ||
        _cardFlipped[index] ||
        _cardMatched[index] ||
        isGameOver) {
      return;
    }

    HapticFeedback.selectionClick();

    setState(() {
      _cardFlipped[index] = true;
      bearState = 'thinking';
    });

    if (_previousIndex == null) {
      _previousIndex = index;
    } else {
      setState(() {
        _moves++;
      });
      _checkForMatch(index);
    }
  }

  // --- 3. MATCHING LOGIC ---
  void _checkForMatch(int currentIndex) {
    final int prevIndex = _previousIndex!;
    final String card1 = _gameBoard[prevIndex];
    final String card2 = _gameBoard[currentIndex];

    _isProcessing = true;

    if (card1 == card2) {
      HapticFeedback.heavyImpact();
      setState(() {
        _cardMatched[prevIndex] = true;
        _cardMatched[currentIndex] = true;
        _isProcessing = false;
        _previousIndex = null;
        bearState = 'happy';
      });

      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted && !isGameOver) setState(() => bearState = 'neutral');
      });

      _checkForWin();
    } else {
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) {
          setState(() {
            _cardFlipped[prevIndex] = false;
            _cardFlipped[currentIndex] = false;
            _isProcessing = false;
            _previousIndex = null;
            bearState = 'neutral';
          });
        }
      });
    }
  }

  // --- 4. WIN LOGIC ---
  Future<void> _checkForWin() async {
    if (_cardMatched.every((bool matched) => matched)) {
      _confettiController.play();
      await _saveScoreToFirebase();

      setState(() {
        isGameOver = true;
        bearState = 'happy';
      });
    }
  }

  Future<void> _saveScoreToFirebase() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final userDoc =
          FirebaseFirestore.instance.collection('users').doc(user.uid);
      final docSnapshot = await userDoc.get();
      int currentBest = docSnapshot.data()?['memoryLowScore'] ?? 999;

      // Lower score is better in Memory Match
      if (_moves < currentBest || currentBest == 0) {
        await userDoc.update({'memoryLowScore': _moves});
      }
    } catch (e) {
      debugPrint("Error saving memory score: $e");
    }
  }

  // --- MAIN BUILD ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("Memory Match",
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          isGameOver ? _buildGameOverScreen() : _buildGameplayScreen(),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- GAMEPLAY SCREEN ---
  Widget _buildGameplayScreen() {
    return Column(
      children: [
        // Stats Header
        Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(30)),
              boxShadow: [
                BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5))
              ]),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("MOVES",
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey)),
                  Text("$_moves",
                      style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87)),
                ],
              ),
              Row(
                children: [
                  Image.asset(
                      bearState == 'happy'
                          ? 'assets/images/games/hooray.png'
                          : bearState == 'thinking'
                              ? 'assets/images/games/oops.png'
                              : 'assets/images/games/search.png',
                      height: 50),
                  const SizedBox(width: 10),
                  if (_isPeeking)
                    Text("Memorize! $_peekCountdown",
                        style: const TextStyle(
                            color: Colors.orange, fontWeight: FontWeight.bold))
                  else
                    Text(bearState == 'happy' ? "Great job!" : "Find a pair!",
                        style: const TextStyle(
                            color: Colors.grey, fontWeight: FontWeight.w500)),
                ],
              )
            ],
          ),
        ),

        // Grid (20 items)
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.85,
            ),
            itemCount: 20,
            itemBuilder: (context, index) {
              return _buildAnimatedCard(index);
            },
          ),
        ),
      ],
    );
  }

  // --- GAME OVER SCREEN ---
  Widget _buildGameOverScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/games/finish.png', height: 180),
            const SizedBox(height: 30),
            const Text("MISSION COMPLETE",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF58C56E),
                    letterSpacing: 1.5)),
            const SizedBox(height: 10),
            Text("Total Moves: $_moves",
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.w500)),
            const SizedBox(height: 40),
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
                            color: primaryColor, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _startNewGame,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("Play Again",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  // --- ANIMATED CARD ---
  Widget _buildAnimatedCard(int index) {
    bool isVisible = _cardFlipped[index] || _cardMatched[index];
    bool isMatched = _cardMatched[index];

    return GestureDetector(
      onTap: () => _onCardTap(index),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          final rotateAnim = Tween(begin: 3.14, end: 0.0).animate(animation);
          return AnimatedBuilder(
            animation: rotateAnim,
            child: child,
            builder: (context, child) {
              final isUnder = (ValueKey(isVisible) != child!.key);
              var tilt = ((animation.value - 0.5).abs() - 0.5) * 0.003;
              tilt *= isUnder ? -1.0 : 1.0;
              final value =
                  isUnder ? min(rotateAnim.value, 3.14 / 2) : rotateAnim.value;
              return Transform(
                transform: Matrix4.rotationY(value)..setEntry(3, 0, tilt),
                alignment: Alignment.center,
                child: child,
              );
            },
          );
        },
        child: isVisible
            ? Container(
                key: const ValueKey(true),
                decoration: BoxDecoration(
                  color: isMatched ? Colors.green.shade50 : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: isMatched ? Colors.green : primaryColor, width: 2),
                  boxShadow: [
                    BoxShadow(
                        color: primaryColor.withValues(alpha: 0.2),
                        blurRadius: 5,
                        offset: const Offset(0, 3))
                  ],
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.asset(
                      'assets/images/dictionary/${_gameBoard[index]}.jpg',
                      fit: BoxFit.contain,
                      errorBuilder: (c, e, s) => Text(
                        _gameBoard[index].toUpperCase(),
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: primaryColor),
                      ),
                    ),
                  ),
                ),
              )
            : Container(
                key: const ValueKey(false),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2))
                  ],
                ),
                child: Center(
                  child: Image.asset(
                    'assets/images/splash.png',
                    color: Colors.white.withValues(alpha: 0.9),
                    width: 30,
                  ),
                ),
              ),
      ),
    );
  }
}
