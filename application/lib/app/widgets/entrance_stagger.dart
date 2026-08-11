import 'package:application/app/theme/animations.dart';
import 'package:flutter/material.dart';

/// Standard entrance animation for page sections.
/// Every section fades and slides in with the same rhythm,
/// so all pages feel coherent.
class EntranceStagger extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final int stepMs;
  final CrossAxisAlignment crossAxisAlignment;

  const EntranceStagger({
    super.key,
    required this.children,
    this.spacing = 32,
    this.stepMs = 80,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        for (var i = 0; i < children.length; i++)
          Padding(
            padding: EdgeInsets.only(
              bottom: i == children.length - 1 ? 0 : spacing,
            ),
            child: FadeInSlide(
              key: ValueKey('entrance_$i'),
              duration: const Duration(milliseconds: 450),
              delay: i * stepMs,
              child: children[i],
            ),
          ),
      ],
    );
  }
}
