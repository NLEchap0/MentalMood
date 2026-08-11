import 'dart:ui';

import 'package:application/app/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Shared glassmorphism card.
/// Near-black glass fill, white hairline border and a neon accent glow.
///
/// IMPORTANT: background and border live INSIDE the BackdropFilter —
/// otherwise the blur would smear them (Flutter blurs everything painted
/// behind the filter, including a parent-decorated border). The neon glow
/// sits OUTSIDE the clip (shadows are clipped away inside ClipRRect).
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final GlassCardSize size;
  final double blur;
  final double opacity;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.size = GlassCardSize.md,
    this.blur = 8,
    this.opacity = 0.045,
  });

  @override
  Widget build(BuildContext context) {
    final radius = switch (size) {
      GlassCardSize.sm => 20.0,
      GlassCardSize.md => 26.0,
      GlassCardSize.lg => 32.0,
    };

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        // Neon glow — must live outside ClipRRect to be visible.
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.10),
            blurRadius: 28,
            spreadRadius: -6,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            width: double.infinity,
            padding: padding,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: opacity),
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.10),
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

enum GlassCardSize { sm, md, lg }
