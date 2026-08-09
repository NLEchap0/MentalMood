import 'dart:async';
import 'package:application/Utils/theme.dart';
import 'package:flutter/material.dart';

enum BreathPhase { ready, inhale, hold, exhale }

class ZenModePage extends StatefulWidget {
  const ZenModePage({super.key});

  @override
  State<ZenModePage> createState() => _ZenModePageState();
}

class _ZenModePageState extends State<ZenModePage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _sizeAnimation;
  
  BreathPhase _phase = BreathPhase.ready;
  String _instruction = "Find a quiet space and settle in.";
  double _progress = 0.0;
  Timer? _timer;
  final Stopwatch _stopwatch = Stopwatch();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 4));
    _sizeAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut)
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _start() async {
    setState(() => _phase = BreathPhase.inhale);
    _runCycle();
  }

  void _runCycle() async {
    if (!mounted || _phase == BreathPhase.ready) return;

    // INHALE
    _updatePhase(BreathPhase.inhale, 4, "Breathe in deeply...");
    _controller.forward(from: 0.0);
    await Future.delayed(const Duration(seconds: 4));
    if (!mounted || _phase == BreathPhase.ready) return;

    // HOLD
    _updatePhase(BreathPhase.hold, 7, "Hold your breath...");
    await Future.delayed(const Duration(seconds: 7));
    if (!mounted || _phase == BreathPhase.ready) return;

    // EXHALE
    _updatePhase(BreathPhase.exhale, 8, "Slowly release everything...");
    _controller.reverse(from: 1.0);
    await Future.delayed(const Duration(seconds: 8));

    if (mounted && _phase != BreathPhase.ready) _runCycle();
  }

  void _updatePhase(BreathPhase p, int sec, String msg) {
    setState(() { _phase = p; _instruction = msg; _progress = 0.0; });
    _stopwatch.reset(); _stopwatch.start();
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 16), (t) {
      if (!mounted || _phase == BreathPhase.ready) { t.cancel(); return; }
      setState(() => _progress = (_stopwatch.elapsedMilliseconds / (sec * 1000)).clamp(0.0, 1.0));
    });
  }

  Color _getPhaseColor() {
    switch (_phase) {
      case BreathPhase.ready: return AppTheme.accent;
      case BreathPhase.inhale: return AppTheme.sagePrimary;
      case BreathPhase.hold: return AppTheme.accent;
      case BreathPhase.exhale: return AppTheme.amberWarm;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _getPhaseColor();

    return Scaffold(
      backgroundColor: AppTheme.backgroundBase,
      body: Stack(
        children: [
          Container(decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient)),
          AnimatedContainer(
            duration: const Duration(seconds: 1),
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [color.withValues(alpha: 0.14), Colors.transparent],
                center: Alignment.center, radius: 1.2,
              ),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.close_rounded, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)), 
                                onPressed: () => Navigator.pop(context)
                              ),
                              const Spacer(),
                              Text(
                                "PANIC BUTTON", 
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                                  letterSpacing: 4
                                )
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
                              width: 320, height: 320,
                              child: CircularProgressIndicator(
                                value: _progress, 
                                strokeWidth: 6, 
                                color: color.withValues(alpha: 0.4), 
                                backgroundColor: Colors.transparent
                              ),
                            ),
                            AnimatedBuilder(
                              animation: _sizeAnimation,
                              builder: (context, child) => Container(
                                width: 260 * _sizeAnimation.value, height: 260 * _sizeAnimation.value,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: color.withValues(alpha: 0.2),
                                  boxShadow: [
                                    BoxShadow(color: color.withValues(alpha: 0.25), blurRadius: 80, spreadRadius: 5)
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    _phase == BreathPhase.ready ? "READY" : _phase.name.toUpperCase(),
                                    style: TextStyle(color: color, fontWeight: FontWeight.w900, letterSpacing: 4, fontSize: 20),
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
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: theme.colorScheme.onSurface, 
                              height: 1.4,
                              fontSize: 22
                            )
                          ),
                        ),
                        const Spacer(),
                        if (_phase == BreathPhase.ready)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(32, 0, 32, 40),
                            child: ElevatedButton(
                              onPressed: _start,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.error,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                                elevation: 8,
                                shadowColor: theme.colorScheme.error.withValues(alpha: 0.5),
                              ),
                              child: const Text(
                                "I NEED SUPPORT NOW", 
                                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1),
                              ),
                            ),
                          )
                        else
                          Padding(
                            padding: const EdgeInsets.only(bottom: 40),
                            child: TextButton(
                              onPressed: () => setState(() {
                                _phase = BreathPhase.ready;
                                _instruction = "Find a quiet space and settle in.";
                                _progress = 0;
                                _controller.stop();
                              }), 
                              child: Text(
                                "STOP SESSION", 
                                style: TextStyle(
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6), 
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1
                                )
                              )
                            ),
                          ),
                      ],
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
