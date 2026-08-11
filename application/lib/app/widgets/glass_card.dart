import 'dart:ui';

import 'package:flutter/material.dart';

/// Shared glassmorphism card.
/// Matches the website hero cards: white 4.5% fill, white 9% border,
/// G3-scaled radius, subtle blur.
///
/// IMPORTANT: background and border live INSIDE the BackdropFilter —
/// otherwise the blur would smear them (Flutter blurs everything painted
/// behind the filter, including a parent-decorated border).
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

    return ClipRRect(
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
              color: Colors.white.withValues(alpha: 0.09),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

enum GlassCardSize { sm, md, lg }
