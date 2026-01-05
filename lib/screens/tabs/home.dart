import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'lessons.dart';
import 'games.dart';
import 'awards.dart';
import 'dictionary.dart';
import 'profile.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    Lessons(),
    Games(),
    Awards(),
    Dictionary(),
    Profile(),
  ];

  @override
  Widget build(BuildContext context) {
    // 1. Wrap with AnnotatedRegion to force the Status Bar to be visible with dark icons
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent, // Transparent bar
        statusBarIconBrightness:
            Brightness.dark, // Black icons (Time, Battery, etc.)
        systemNavigationBarColor: Colors.white, // White bottom bar area
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        // 2. Wrap the body in a SafeArea to ensure content doesn't go under the status bar
        body: SafeArea(
          bottom: false, // We want the bottom bar to stay at the bottom
          child: _screens[_selectedIndex],
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(13),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: BottomNavigationBar(
            backgroundColor: Colors.white,
            type: BottomNavigationBarType.fixed,
            currentIndex: _selectedIndex,
            selectedItemColor: const Color(0xFF58C56E),
            unselectedItemColor: Colors.grey,
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            items: [
              BottomNavigationBarItem(
                icon: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.menu_book,
                    size: _selectedIndex == 0 ? 28 : 24,
                  ),
                ),
                label: 'Lessons',
              ),
              BottomNavigationBarItem(
                icon: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.sports_esports_rounded,
                    size: _selectedIndex == 1 ? 28 : 26,
                  ),
                ),
                label: 'Games',
              ),
              BottomNavigationBarItem(
                icon: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.workspace_premium_rounded,
                    size: _selectedIndex == 2 ? 28 : 24,
                  ),
                ),
                label: 'Awards',
              ),
              BottomNavigationBarItem(
                icon: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.book,
                    size: _selectedIndex == 3 ? 28 : 22,
                  ),
                ),
                label: 'Dictionary',
              ),
              BottomNavigationBarItem(
                icon: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.person,
                    size: _selectedIndex == 4 ? 28 : 24,
                  ),
                ),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
