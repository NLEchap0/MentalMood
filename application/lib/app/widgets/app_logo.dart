import 'package:application/app/theme/app_colors.dart';
import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double size;
  const AppLogo({super.key, this.size = 100});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size * 1.2,
        height: size * 1.2,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Neural Aura (Outer Glow)
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accent.withValues(alpha: 0.05),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.1),
                    blurRadius: size * 0.4,
                    spreadRadius: size * 0.05,
                  ),
                ],
              ),
            ),
            // Inner Glass Ring
            Container(
              width: size * 0.76,
              height: size * 0.76,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.08),
                  width: 1,
                ),
              ),
            ),
            // Core Unit
            Container(
              width: size * 0.56,
              height: size * 0.56,
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: size * 0.15,
                    offset: Offset(0, size * 0.05),
                  ),
                ],
              ),
              child: Center(
                child: ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [AppColors.accent, AppColors.gold],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds),
                  child: Icon(
                    Icons.bubble_chart_rounded,
                    color: Colors.white,
                    size: size * 0.32,
                  ),
                ),
              ),
            ),
            // Floating Insight Spark
            Positioned(
              top: size * 0.3,
              right: size * 0.3,
              child: Container(
                width: size * 0.06,
                height: size * 0.06,
                decoration: const BoxDecoration(
                  color: AppColors.gold,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.gold,
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
