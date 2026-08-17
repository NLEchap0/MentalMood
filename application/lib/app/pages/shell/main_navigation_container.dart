import 'dart:ui';

import 'package:application/app/navigation/app_navigator.dart';
import 'package:application/app/pages/home/home_page.dart';
import 'package:application/app/pages/journal/add_mood_page.dart';
import 'package:application/app/pages/journal/mood_history_page.dart';
import 'package:application/app/pages/growth/zen_mode_page.dart';
import 'package:application/app/pages/settings/settings_page.dart';
import 'package:application/app/theme/app_colors.dart';
import 'package:application/app/theme/animations.dart';
import 'package:application/app/widgets/app_button.dart';
import 'package:application/state/auth_controller.dart';
import 'package:application/state/mood_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MainNavigationContainer extends StatefulWidget {
  const MainNavigationContainer({super.key});

  @override
  State<MainNavigationContainer> createState() =>
      _MainNavigationContainerState();
}

class _MainNavigationContainerState extends State<MainNavigationContainer> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = [
    HomePage(),
    MoodHistoryPage(),
    SettingsPage(),
  ];

  @override
  void initState() {
    super.initState();
    // Load the user's mood history (and tags/badges) once on app start,
    // after the first frame so providers are ready.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthController>().currentUser;
      if (user != null) {
        context.read<MoodController>().fetchMoodHistory(user.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // IndexedStack keeps each tab's state (filters, form fields)
          // alive while switching, instead of disposing it.
          IndexedStack(index: _selectedIndex, children: _pages),
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Center(
              child: FadeInSlide(
                delay: 600,
                direction: const Offset(0, 20),
                child: _buildActionPill(context),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
          ),
        ),
        child: NavigationBar(
          backgroundColor: AppColors.backgroundBase,
          indicatorColor: AppColors.accent.withValues(alpha: 0.14),
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) =>
              setState(() => _selectedIndex = index),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined, color: Colors.white54, size: 22),
              selectedIcon: Icon(
                Icons.home_rounded,
                color: AppColors.accent,
                size: 22,
              ),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(
                Icons.auto_stories_outlined,
                color: Colors.white54,
                size: 22,
              ),
              selectedIcon: Icon(
                Icons.auto_stories_rounded,
                color: AppColors.accent,
                size: 22,
              ),
              label: 'Journal',
            ),
            NavigationDestination(
              icon: Icon(
                Icons.person_outline_rounded,
                color: Colors.white54,
                size: 22,
              ),
              selectedIcon: Icon(
                Icons.person_rounded,
                color: AppColors.accent,
                size: 22,
              ),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionPill(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        shape: const ContinuousRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(80)),
          side: BorderSide.none,
        ),
        shadows: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          height: 68,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.85),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () =>
                    AppNavigator.push(context, const ZenModePage()),
                icon: const Icon(
                  Icons.air_rounded,
                  color: AppColors.accent,
                  size: 24,
                ),
                tooltip: 'Breathe',
              ),
              const SizedBox(width: 4),
              AppButton(
                key: const Key('shell_add_checkin'),
                label: 'Add Check-in',
                icon: Icons.add_rounded,
                variant: AppButtonVariant.accent,
                onPressed: () =>
                    AppNavigator.push(context, const AddMoodPage()),
                isFullWidth: false,
              ),
              const SizedBox(width: 4),
            ],
          ),
        ),
      ),
    );
  }
}
