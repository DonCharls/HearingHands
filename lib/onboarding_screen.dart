import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/tabs/home.dart'; // Ensure correct path
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;
  final Color primaryGreen = const Color(0xFF58C56E);

  // Helper to handle navigation to Home
  void _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seenOnboarding', true);
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Home()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine the color of UI elements based on the page
    final bool isFirstPage = _currentPage == 0;
    final Color uiElementColor = isFirstPage ? Colors.white : primaryGreen;

    return Scaffold(
      // AnimatedSwitcher makes background transitions smoother
      body: Stack(
        children: [
          PageView(
            controller: _controller,
            onPageChanged: (index) => setState(() => _currentPage = index),
            children: [
              // PAGE 1: HERO/WELCOME
              _buildPage(
                title: 'Welcome to HearingHands',
                description:
                    'An inclusive app to bridge communication gaps for the Filipino deaf and mute community.',
                image: 'assets/images/logo.png',
                bgColor: const Color(0xFF4F965E),
                isDark: true,
              ),
              // PAGE 2: EMPOWER
              _buildPage(
                title: 'Empowering Connections',
                description:
                    'Break down barriers and create meaningful connections between everyone.',
                image: 'assets/images/talkbearr.png',
                bgColor: Colors.white,
                isDark: false,
              ),
              // PAGE 3: CONCLUDE
              _buildPage(
                title: 'Effortless Communication',
                description:
                    'Sharing ideas becomes effortless, fostering understanding for everyone.',
                image: 'assets/images/groupbear.png',
                bgColor: Colors.white,
                isDark: false,
              ),
            ],
          ),

          // --- TOP NAV: BACK BUTTON ---
          if (_currentPage > 0)
            Positioned(
              top: 50,
              left: 10,
              child: IconButton(
                icon: Icon(Icons.arrow_back_ios_new,
                    color: uiElementColor, size: 24),
                onPressed: () => _controller.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                ),
              ),
            ),

          // --- BOTTOM NAV: BUTTON & INDICATOR ---
          Positioned(
            bottom: 50,
            left: 30,
            right: 30,
            child: Column(
              children: [
                SmoothPageIndicator(
                  controller: _controller,
                  count: 3,
                  effect: ExpandingDotsEffect(
                    activeDotColor: uiElementColor,
                    dotColor:
                        isFirstPage ? Colors.white54 : Colors.grey.shade300,
                    dotHeight: 8,
                    dotWidth: 8,
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _currentPage == 2
                        ? _finishOnboarding
                        : () {
                            _controller.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isFirstPage ? Colors.white : primaryGreen,
                      foregroundColor:
                          isFirstPage ? primaryGreen : Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                    ),
                    child: Text(
                      _currentPage == 0
                          ? 'Let\'s Get Started'
                          : (_currentPage == 2 ? 'Get Started' : 'Continue'),
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // A single, unified page builder for better consistency
  Widget _buildPage({
    required String title,
    required String description,
    required String image,
    required Color bgColor,
    required bool isDark,
  }) {
    final Color textColor = isDark ? Colors.white : Colors.black87;

    return Container(
      color: bgColor,
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Image Area
          Image.asset(image, height: 280, fit: BoxFit.contain),
          const SizedBox(height: 40),
          // Text Area
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : primaryGreen,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: textColor.withValues(alpha: 0.8),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 100), // Space for the bottom UI
        ],
      ),
    );
  }
}
