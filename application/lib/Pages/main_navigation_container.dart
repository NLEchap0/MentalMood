import 'dart:ui';
import 'package:application/Pages/home_page.dart';
import 'package:application/Pages/Mood/mood_history_page.dart';
import 'package:application/Pages/Mood/add_mood_page.dart';
import 'package:application/Pages/Settings/settings_page.dart';
import 'package:application/Utils/theme.dart';
import 'package:application/Utils/animations.dart';
import 'package:flutter/material.dart';

class MainNavigationContainer extends StatefulWidget {
  const MainNavigationContainer({super.key});

  @override
  State<MainNavigationContainer> createState() => _MainNavigationContainerState();
}

class _MainNavigationContainerState extends State<MainNavigationContainer> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const MoodHistoryPage(),
    const SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: Stack(
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.05, 0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: Container(
                key: ValueKey<int>(_selectedIndex),
                child: _pages[_selectedIndex],
              ),
            ),
            
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Center(
                child: FadeInSlide(
                  delay: 800,
                  direction: const Offset(0, 20),
                  child: _buildPersistentActionPill(context),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
        ),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: NavigationBar(
            backgroundColor: AppTheme.backgroundBase,
            indicatorColor: AppTheme.accent.withValues(alpha: 0.1),
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) => setState(() => _selectedIndex = index),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined, color: Colors.white54, size: 20),
                selectedIcon: Icon(Icons.home_rounded, color: AppTheme.accent, size: 20),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.auto_stories_outlined, color: Colors.white54, size: 20),
                selectedIcon: Icon(Icons.auto_stories_rounded, color: AppTheme.accent, size: 20),
                label: 'Journal',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline_rounded, color: Colors.white54, size: 20),
                selectedIcon: Icon(Icons.person_rounded, color: AppTheme.accent, size: 20),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPersistentActionPill(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        shape: const ContinuousRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(80)),
          side: BorderSide.none,
        ),
        shadows: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 25, offset: const Offset(0, 10))
        ],
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          height: 68,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E2E).withValues(alpha: 0.8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () => Navigator.pushNamed(context, '/zen'),
                icon: const Icon(Icons.air_rounded, color: AppTheme.terracottaError, size: 24),
                tooltip: "Breathe",
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const AddMoodPage())),
                icon: const Icon(Icons.add_rounded, color: Colors.white, size: 24),
                label: const Text(
                  "SYNC STATE", 
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1.2, fontSize: 13)
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
    );
  }
}
