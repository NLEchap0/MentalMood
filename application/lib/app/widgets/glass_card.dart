import 'dart:ui';

import 'package:application/app/theme/app_tokens.dart';
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
    this.blur = 15,
    this.opacity = 0.045,
  });

  @override
  Widget build(BuildContext context) {
    final radius = switch (size) {
      GlassCardSize.sm => AppTokens.radiusSm,
      GlassCardSize.md => AppTokens.radiusMd,
      GlassCardSize.lg => AppTokens.radiusLg,
    };
    final shape =
        customShape ??
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
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
