import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Required for SystemChrome
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'screens/tabs/home.dart';
import 'splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // --- START OF FIX ---

  // 1. Enable "Edge-to-Edge" mode.
  // This tells the app to draw BEHIND the system bars, so the screen doesn't "shrink".
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // 2. Make the bars transparent.
  // This lets you see the Status Bar (Top) and makes the Bottom Bar float over content
  // instead of pushing it up.
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    // Status Bar (Top)
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark, // Use .light for dark backgrounds

    // Navigation Bar (Bottom)
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness:
        Brightness.dark, // Use .light for dark backgrounds
    systemNavigationBarDividerColor: Colors.transparent,
  ));

  // --- END OF FIX ---

  final prefs = await SharedPreferences.getInstance();
  final bool seenOnboarding = prefs.getBool('seenOnboarding') ?? false;

  runApp(MyApp(seenOnboarding: seenOnboarding));
}

class MyApp extends StatelessWidget {
  final bool seenOnboarding;
  const MyApp({super.key, required this.seenOnboarding});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HearingHands',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.white,
        // Optional: Ensure Material 3 is used for better transparency support
        useMaterial3: true,
      ),
      home: seenOnboarding ? const Home() : const SplashScreen(),
    );
  }
}
