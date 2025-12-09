import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/tabs/home.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

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
                imageAsset: 'assets/images/logo.png',
                showImage: true,
                startColor: const Color(0xFF4F965E),
                textColor: Colors.white,
              ),
              buildCenteredPage(
                title: 'Empowering Connections',
                description:
                    'HearingHands empowers communication between hearing individuals and the deaf and mute community, breaking down barriers to create meaningful connections.',
                imageAsset: 'assets/images/talkbearr.png',
                textColor: const Color(0xFF58C56E),
              ),
              buildCenteredPage(
                title: 'Effortless Communication for All',
                description:
                    'With HearingHands, sharing ideas and conversations become effortless, fostering understanding and inclusivity for everyone.',
                imageAsset: 'assets/images/groupbear.png',
                textColor: const Color(0xFF58C56E),
              ),
            ],
          ),
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
                    onPressed: () async {
                      if (_currentPage == 2) {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setBool('seenOnboarding', true);
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

  Widget buildPage({
    required String title,
    required String subtitle,
    required String description,
    required String imageAsset,
    bool showImage = true,
    Color? startColor,
    Color? endColor,
    Color textColor = Colors.black,
  }) {
    return Container(
      decoration: BoxDecoration(color: startColor),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 60),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Welcome to\nHearingHands",
              style: TextStyle(
                fontSize: 38,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Let's learn Filipino Sign Language together",
              style: TextStyle(fontSize: 14, color: textColor),
            ),
            const SizedBox(height: 40),
            Center(
              child: Image.asset(
                imageAsset,
                width: 250,
                height: 250,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                "Start your journey to learn Filipino Sign Language with ease.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: textColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCenteredPage({
    required String title,
    required String description,
    required String imageAsset,
    Color textColor = Colors.black,
  }) {
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
            child: Image.asset(
              imageAsset,
              width: 360,
              height: 340,
              fit: BoxFit.cover,
            ),
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
