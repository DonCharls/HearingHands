import 'package:flutter/material.dart';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'screens/tabs/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HearingHands',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const SplashScreen(),
    );
  }
}

// SPLASH SCREEN
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(_fadeController);
    _startSplash();
  }

  void _startSplash() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _fadeController.forward();

    await _audioPlayer.play(AssetSource('audios/intro.mp3'));
    _audioPlayer.onPlayerComplete.listen((event) {
      _navigateToOnboarding();
    });
  }

  void _navigateToOnboarding() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 800),
        pageBuilder: (_, __, ___) => const OnboardingScreen(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child:
              Image.asset('assets/images/hhlogo.png', width: 150, height: 150),
        ),
      ),
    );
  }
}

// ONBOARDING SCREEN
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _controller,
            physics: const NeverScrollableScrollPhysics(),
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            children: [
              buildPage(
                title: 'Welcome to',
                subtitle: 'HearingHands',
                description:
                    'An inclusive app to bridge communication gaps\nfor the deaf and mute community.',
                imageAsset: 'assets/images/hand.png',
                showImage: true,
                startColor: const Color(0xFF4F965E),
                endColor: const Color(0xFF213F28),
                textColor: Colors.white,
              ),
              buildCenteredPage(
                title: 'Empowering Connections',
                description:
                    'HearingHands empowers communication between hearing individuals and the deaf and mute community, breaking down barriers to create meaningful connections.',
                imageAsset: 'assets/images/talk.png',
                textColor: const Color(0xFF58C56E),
              ),
              buildCenteredPage(
                title: 'Effortless Communication for All',
                description:
                    'With HearingHands, sharing ideas and conversations become effortless, fostering understanding and inclusivity for everyone.',
                imageAsset: 'assets/images/group.jpg',
                textColor: const Color(0xFF58C56E),
              ),
            ],
          ),

          // BACK ICON
          if (_currentPage >= 1)
            Positioned(
              top: 55,
              left: 15,
              child: IconButton(
                icon:
                    const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                onPressed: () {
                  _controller.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
              ),
            ),

          // BUTTONS
          Positioned(
            bottom: 80,
            left: 30,
            right: 30,
            child: _currentPage == 0
                ? ElevatedButton(
                    onPressed: () {
                      _controller.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF58C56E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: const Text('Let\'s Get Started',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                  )
                : ElevatedButton(
                    onPressed: () {
                      if (_currentPage == 2) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const Home()),
                        );
                      } else {
                        _controller.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF58C56E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: const Text('Continue',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                  ),
          ),

          // INDICATOR
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: SmoothPageIndicator(
                controller: _controller,
                count: 3,
                effect: ExpandingDotsEffect(
                  activeDotColor: const Color(0xFF58C56E),
                  dotColor: Colors.grey.shade400,
                  dotHeight: 8,
                  dotWidth: 8,
                  expansionFactor: 3,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPage(
      {required String title,
      required String subtitle,
      required String description,
      required String imageAsset,
      bool showImage = true,
      Color? startColor,
      Color? endColor,
      Color textColor = Colors.black}) {
    return Container(
      decoration: BoxDecoration(
        gradient: (startColor != null && endColor != null)
            ? LinearGradient(
                colors: [startColor, endColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight)
            : null,
        color: (startColor == null || endColor == null) ? Colors.white : null,
      ),
      child: Stack(
        children: [
          if (showImage)
            Opacity(
              opacity: 0.60,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Image.asset(imageAsset,
                    width: 515, height: 515, fit: BoxFit.contain),
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 60),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Transform.translate(
                  offset: const Offset(0, 30),
                  child: Text(title,
                      style: TextStyle(
                          fontFamily: 'Whisper',
                          fontSize: 45,
                          color: textColor)),
                ),
                Transform.translate(
                  offset: const Offset(0, 10),
                  child: Text(subtitle,
                      style: TextStyle(
                          fontSize: 45,
                          fontWeight: FontWeight.bold,
                          color: textColor)),
                ),
                Transform.translate(
                  offset: const Offset(0, 10),
                  child: Text(description,
                      textAlign: TextAlign.left,
                      style: TextStyle(fontSize: 12, color: textColor)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCenteredPage(
      {required String title,
      required String description,
      required String imageAsset,
      Color textColor = Colors.black}) {
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 30),
          ClipRRect(
            borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20)),
            child: Image.asset(imageAsset,
                width: 360, height: 340, fit: BoxFit.cover),
          ),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
            child: Column(
              children: [
                Text(title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: textColor)),
                const SizedBox(height: 10),
                Text(description,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: textColor)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
