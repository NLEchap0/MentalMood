import 'dart:async';
import 'package:flutter/material.dart';

class FadeInSlide extends StatelessWidget {
  final Widget child;
  final int duration;
  final Offset direction;
  final int delay;

  const FadeInSlide({
    super.key,
    this.duration = 500,
    this.direction = const Offset(0, 15),
    this.delay = 0,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.delayed(Duration(milliseconds: delay)),
      builder: (context, snapshot) {
        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: duration),
          tween: Tween(begin: 0.0, end: 1.0),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: direction * (1.0 - value),
                child: child,
              ),
            );
          },
          child: child,
        );
      },
    );
  }
}

class ScaleIn extends StatelessWidget {
  final Widget child;
  final int duration;
  final int delay;

  const ScaleIn({
    super.key,
    this.duration = 500,
    this.delay = 0,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.delayed(Duration(milliseconds: delay)),
      builder: (context, snapshot) {
        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: duration),
          tween: Tween(begin: 0.0, end: 1.0),
          curve: Curves.elasticOut,
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: child,
            );
          },
          child: child,
        );
      },
    );
  }
}

class HoverEffect extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scale;
  final ShapeBorder? customBorder;
  final String? tooltip;
  final Duration? tooltipDelay;
  
  const HoverEffect({
    super.key, 
    required this.child, 
    this.onTap,
    this.scale = 1.015,
    this.customBorder,
    this.tooltip,
    this.tooltipDelay,
  });

  @override
  State<HoverEffect> createState() => _HoverEffectState();
}

class _HoverEffectState extends State<HoverEffect> {
  bool _isHovered = false;
  Timer? _timer;
  final GlobalKey<TooltipState> _tooltipKey = GlobalKey<TooltipState>();

  void _handleMouseEnter() {
    setState(() => _isHovered = true);
    if (widget.tooltip != null) {
      _timer?.cancel();
      _timer = Timer(widget.tooltipDelay ?? const Duration(seconds: 1), () {
        if (mounted && _isHovered) {
          _tooltipKey.currentState?.ensureTooltipVisible();
        }
      });
    }
  }

  void _handleMouseExit() {
    setState(() => _isHovered = false);
    _timer?.cancel();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ShapeBorder effectiveShape = widget.customBorder ?? const ContinuousRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(56)));

    Widget content = AnimatedScale(
      scale: _isHovered ? widget.scale : 1.0,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(shape: effectiveShape),
        child: Stack(
          children: [
            widget.child,
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: ShapeDecoration(
                    shape: effectiveShape,
                    color: _isHovered ? Colors.white.withValues(alpha: 0.12) : Colors.transparent,
                  ),
                ),
              ),
            ),
            if (widget.onTap != null)
              Positioned.fill(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: widget.onTap,
                    mouseCursor: SystemMouseCursors.click,
                    customBorder: effectiveShape,
                    splashColor: Colors.white.withValues(alpha: 0.1),
                    highlightColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                  ),
                ),
              ),
          ],
        ),
      ),
    );

    if (widget.tooltip != null) {
      return Tooltip(
        key: _tooltipKey,
        message: widget.tooltip!,
        // We set an impossible waitDuration to disable native trigger
        waitDuration: const Duration(hours: 1), 
        child: MouseRegion(
          onEnter: (_) => _handleMouseEnter(),
          onExit: (_) => _handleMouseExit(),
          cursor: widget.onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
          child: content,
        ),
      );
    }

    return MouseRegion(
      onEnter: (_) => _handleMouseEnter(),
      onExit: (_) => _handleMouseExit(),
      cursor: widget.onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: content,
    );
  }
}

typedef EntranceAnimation = FadeInSlide;
typedef InteractiveCard = HoverEffect;
