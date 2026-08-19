import 'dart:async';

import 'package:application/app/theme/app_colors.dart';
import 'package:application/app/theme/app_tokens.dart';
import 'package:application/app/widgets/app_background.dart';
import 'package:flutter/material.dart';

enum BreathPhase { ready, inhale, hold, exhale }

class ZenModePage extends StatefulWidget {
  const ZenModePage({super.key});

  @override
  State<ZenModePage> createState() => _ZenModePageState();
}

class _ZenModePageState extends State<ZenModePage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _sizeAnimation;

  BreathPhase _phase = BreathPhase.ready;
  String _instruction = 'Find a quiet space and settle in.';
  double _progress = 0.0;
  Timer? _timer;
  final Stopwatch _stopwatch = Stopwatch();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _sizeAnimation = Tween<double>(
      begin: 0.4,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _start() {
    setState(() => _phase = BreathPhase.inhale);
    _runCycle();
  }

  void _stop() {
    _timer?.cancel();
    _stopwatch.stop();
    _controller.stop();
    setState(() {
      _phase = BreathPhase.ready;
      _instruction = 'Find a quiet space and settle in.';
      _progress = 0;
    });
  }

  Future<void> _runCycle() async {
    if (!mounted || _phase == BreathPhase.ready) return;

    _updatePhase(BreathPhase.inhale, 4, 'Breathe in deeply...');
    _controller.forward(from: 0.0);
    await Future.delayed(const Duration(seconds: 4));
    if (!mounted || _phase == BreathPhase.ready) return;

    _updatePhase(BreathPhase.hold, 7, 'Hold your breath...');
    await Future.delayed(const Duration(seconds: 7));
    if (!mounted || _phase == BreathPhase.ready) return;

    _updatePhase(BreathPhase.exhale, 8, 'Slowly release everything...');
    _controller.reverse(from: 1.0);
    await Future.delayed(const Duration(seconds: 8));

    if (mounted && _phase != BreathPhase.ready) _runCycle();
  }

  void _updatePhase(BreathPhase phase, int seconds, String message) {
    setState(() {
      _phase = phase;
      _instruction = message;
      _progress = 0.0;
    });
    _stopwatch.reset();
    _stopwatch.start();
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 16), (t) {
      if (!mounted || _phase == BreathPhase.ready) {
        t.cancel();
        return;
      }
      setState(() {
        _progress = (_stopwatch.elapsedMilliseconds / (seconds * 1000)).clamp(
          0.0,
          1.0,
        );
      });
    });
  }

  Color get _phaseColor => switch (_phase) {
    BreathPhase.ready => AppColors.accent,
    BreathPhase.inhale => AppColors.success,
    BreathPhase.hold => AppColors.accent,
    BreathPhase.exhale => AppColors.gold,
  };

  @override
  Widget build(BuildContext context) {
    final color = _phaseColor;

    return Scaffold(
      backgroundColor: AppColors.backgroundBase,
      body: Stack(
        children: [
          const AppBackground(child: SizedBox.expand()),
          AnimatedContainer(
            duration: const Duration(seconds: 1),
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [color.withValues(alpha: 0.16), Colors.transparent],
                center: Alignment.center,
                radius: 1.1,
              ),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                        maxWidth: 640,
                      ),
                      child: IntrinsicHeight(
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.close_rounded,
                                      color: AppColors.textSecondary,
                                    ),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                  const Spacer(),
                                  const Text(
                                    'PANIC BUTTON',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 4,
                                      color: AppColors.textFaint,
                                    ),
                                  ),
                                  const Spacer(),
                                  const SizedBox(width: 48),
                                ],
                              ),
                            ),
                            const Spacer(),
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: 320,
                                  height: 320,
                                  child: CircularProgressIndicator(
                                    value: _progress,
                                    strokeWidth: 6,
                                    color: color.withValues(alpha: 0.35),
                                    backgroundColor: Colors.transparent,
                                  ),
                                ),
                                AnimatedBuilder(
                                  animation: _sizeAnimation,
                                  builder: (context, child) => Container(
                                    width: 260 * _sizeAnimation.value,
                                    height: 260 * _sizeAnimation.value,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: color.withValues(alpha: 0.18),
                                      boxShadow: [
                                        BoxShadow(
                                          color: color.withValues(alpha: 0.22),
                                          blurRadius: 80,
                                          spreadRadius: 5,
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Text(
                                        _phase == BreathPhase.ready
                                            ? 'READY'
                                            : _phase.name.toUpperCase(),
                                        style: TextStyle(
                                          color: color,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 4,
                                          fontSize: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 48),
                              child: Text(
                                _instruction,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  height: 1.4,
                                  fontSize: 21,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const Spacer(),
                            if (_phase == BreathPhase.ready)
                              Padding(
                                padding: const EdgeInsets.fromLTRB(32, 0, 32, 40),
                                child: FilledButton.icon(
                                  onPressed: _start,
                                  style: FilledButton.styleFrom(
                                    backgroundColor: AppColors.danger,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 40,
                                      vertical: 22,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        AppTokens.radiusPill,
                                      ),
                                    ),
                                    elevation: 8,
                                    shadowColor: AppColors.danger.withValues(
                                      alpha: 0.5,
                                    ),
                                  ),
                                  icon: const Icon(Icons.spa_rounded, size: 20),
                                  label: const Text(
                                    'I Need Support Now',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              )
                            else
                              Padding(
                                padding: const EdgeInsets.only(bottom: 40),
                                child: TextButton(
                                  onPressed: _stop,
                                  child: const Text(
                                    'Stop breathing',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
