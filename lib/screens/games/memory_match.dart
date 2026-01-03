import 'dart:async';
import 'package:flutter/material.dart';

class MemoryMatchGame extends StatefulWidget {
  const MemoryMatchGame({super.key});

  @override
  State<MemoryMatchGame> createState() => _MemoryMatchGameState();
}

class _MemoryMatchGameState extends State<MemoryMatchGame> {
  // --- CONFIGURATION ---
  final Color primaryColor = const Color(0xFF58C56E);

  // --- GAME STATE VARIABLES ---
  // The actual data behind the cards (e.g., "a", "b", "a", "c")
  List<String> _gameBoard = [];
  
  // Tracks if a card is currently facing up
  List<bool> _cardFlipped = [];
  
  // Tracks if a card has been permanently matched
  List<bool> _cardMatched = [];

  // Logic variables
  int? _previousIndex; // The index of the first card tapped
  bool _isProcessing = false; // Prevents tapping while animating
  int _moves = 0; // Move counter

  @override
  void initState() {
    super.initState();
    _startNewGame();
  }

  // --- 1. SETUP LOGIC ---
  void _startNewGame() {
    setState(() {
      // 1. Pick 8 letters (A-H) to make 8 pairs
      List<String> letters = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'];
      
      // 2. Duplicate them to make pairs (8 * 2 = 16 cards)
      _gameBoard = [...letters, ...letters];
      
      // 3. Shuffle the board
      _gameBoard.shuffle();

      // 4. Reset state lists
      _cardFlipped = List.generate(16, (index) => false);
      _cardMatched = List.generate(16, (index) => false);
      
      // 5. Reset counters
      _previousIndex = null;
      _isProcessing = false;
      _moves = 0;
    });
  }

  // --- 2. TAP INTERACTION ---
  void _onCardTap(int index) {
    // IGNORE TAP IF: 
    // - Game is processing a mismatch
    // - Card is already flipped
    // - Card is already matched
    if (_isProcessing || _cardFlipped[index] || _cardMatched[index]) return;

    setState(() {
      _cardFlipped[index] = true; // Flip the card up
    });

    if (_previousIndex == null) {
      // CASE: This is the FIRST card tapped
      _previousIndex = index;
    } else {
      // CASE: This is the SECOND card tapped
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

    // Lock the board so user can't tap a 3rd card immediately
    _isProcessing = true;

    if (card1 == card2) {
      // --- MATCH FOUND ---
      setState(() {
        _cardMatched[prevIndex] = true;
        _cardMatched[currentIndex] = true;
        _isProcessing = false;
        _previousIndex = null;
      });
      _checkForWin();
    } else {
      // --- NO MATCH ---
      // Wait 1 second so user can see what they picked, then flip back
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            _cardFlipped[prevIndex] = false;
            _cardFlipped[currentIndex] = false;
            _isProcessing = false;
            _previousIndex = null;
          });
        }
      });
    }
  }

  // --- 4. WIN LOGIC ---
  void _checkForWin() {
    // If every card is matched, Game Over
    if (_cardMatched.every((bool matched) => matched)) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text("Success!"),
          content: Text("You won in $_moves moves."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _startNewGame(); // Restart
              },
              child: const Text("Play Again"),
            ),
             TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Exit screen
              },
              child: const Text("Exit"),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Memory Match"),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _startNewGame,
          )
        ],
      ),
      body: Column(
        children: [
          // Info Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Moves: $_moves",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          
          // The Grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4, // 4 columns
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.8, // Taller cards
              ),
              itemCount: 16,
              itemBuilder: (context, index) {
                return _buildCard(index);
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- SIMPLE CARD WIDGET ---
  Widget _buildCard(int index) {
    // Determine state
    bool isVisible = _cardFlipped[index] || _cardMatched[index];

    return GestureDetector(
      onTap: () => _onCardTap(index),
      child: Container(
        decoration: BoxDecoration(
          color: isVisible ? Colors.white : primaryColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: primaryColor, width: 2),
        ),
        child: Center(
          child: isVisible
              ? Image.asset(
                  // Uses your existing dictionary images (a.jpg, b.jpg...)
                  'assets/images/dictionary/${_gameBoard[index]}.jpg', 
                  fit: BoxFit.contain,
                  // If image fails, show text instead (Safety Fallback)
                  errorBuilder: (c, e, s) => Text(
                    _gameBoard[index].toUpperCase(),
                    style: TextStyle(
                      fontSize: 32, 
                      fontWeight: FontWeight.bold, 
                      color: primaryColor
                    ),
                  ),
                )
              : const Icon(Icons.question_mark, color: Colors.white, size: 32),
        ),
      ),
    );
  }
}