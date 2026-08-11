import 'dart:ui';

import 'package:flutter/material.dart';

/// Shared glassmorphism card. Radius scales with the card size
/// (sm = small tiles, md = default cards, lg = hero panels).
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final ShapeBorder? customShape;
  final GlassCardSize size;
  final double blur;
  final double opacity;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.customShape,
    this.size = GlassCardSize.md,
    this.blur = 8,
    this.opacity = 0.045,
  });

  @override
  Widget build(BuildContext context) {
    // Matches the website hero cards: white 4.5% fill, white 9% border,
    // 26px G3 radius, subtle blur.
    final radius = switch (size) {
      GlassCardSize.sm => 20.0,
      GlassCardSize.md => 26.0,
      GlassCardSize.lg => 32.0,
    };
    final shape =
        customShape ??
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.09)),
        );

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(shape: shape),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          width: double.infinity,
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: opacity),
          ),
          child: child,
        ),
      ),
    );
  }
}

enum GlassCardSize { sm, md, lg }
