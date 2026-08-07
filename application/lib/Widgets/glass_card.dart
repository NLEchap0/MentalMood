import 'dart:ui';
import 'package:application/Utils/theme.dart';
import 'package:flutter/material.dart';

/// Centralized Glassmorphism Card with G3/Apple standard curvature.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? height;
  final double? width;
  final ShapeBorder? customShape;
  final double blur;
  final double opacity;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.height,
    this.width,
    this.customShape,
    this.blur = 15.0,
    this.opacity = 0.05,
  });

  @override
  Widget build(BuildContext context) {
    final shape = customShape ?? AppTheme.g3CardShape;

    return Container(
      height: height,
      width: width,
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(shape: shape),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
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
