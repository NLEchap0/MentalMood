import 'dart:async';
import 'package:application/app/theme/app_colors.dart';
import 'package:flutter/material.dart';

enum AppToastType { success, error, info }

class AppToast {
  static final List<_ToastEntry> _activeToasts = [];

  static void show(
    BuildContext context,
    String message, {
    AppToastType type = AppToastType.info,
  }) {
    final overlay = Overlay.of(context);
    final topPadding = MediaQuery.of(context).padding.top;

    late OverlayEntry entry;
    
    // Creazione del widget del toast
    entry = OverlayEntry(
      builder: (context) {
        // Calcoliamo la posizione verticale basata su quanti toast sono già presenti
        final index = _activeToasts.indexWhere((e) => e.entry == entry);
        if (index == -1) return const SizedBox.shrink();

        final yOffset = topPadding + 10 + (index * 45.0);

        return _ToastWidget(
          key: ValueKey(entry.hashCode),
          message: message,
          type: type,
          topOffset: yOffset,
          onDismiss: () {
            _removeEntry(entry);
          },
        );
      },
    );

    _activeToasts.add(_ToastEntry(entry: entry));
    overlay.insert(entry);
    
    // Forza un rebuild degli altri toast per aggiornare le posizioni
    for (var e in _activeToasts) {
      if (e.entry != entry) e.entry.markNeedsBuild();
    }
  }

  static void _removeEntry(OverlayEntry entry) {
    if (_activeToasts.any((e) => e.entry == entry)) {
      _activeToasts.removeWhere((e) => e.entry == entry);
      entry.remove();
      // Aggiorna le posizioni dei toast rimanenti
      for (var e in _activeToasts) {
        e.entry.markNeedsBuild();
      }
    }
  }
}

class _ToastEntry {
  final OverlayEntry entry;
  _ToastEntry({required this.entry});
}

class _ToastWidget extends StatefulWidget {
  final String message;
  final AppToastType type;
  final double topOffset;
  final VoidCallback onDismiss;

  const _ToastWidget({
    super.key,
    required this.message,
    required this.type,
    required this.topOffset,
    required this.onDismiss,
  });

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();

    _timer = Timer(const Duration(seconds: 3), () async {
      if (mounted) {
        await _controller.reverse();
        widget.onDismiss();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color accentColor = switch (widget.type) {
      AppToastType.success => AppColors.success,
      AppToastType.error => AppColors.danger,
      AppToastType.info => AppColors.accent,
    };

    final IconData icon = switch (widget.type) {
      AppToastType.success => Icons.check_circle_rounded,
      AppToastType.error => Icons.error_outline_rounded,
      AppToastType.info => Icons.info_outline_rounded,
    };

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 400),
      curve: Curves.fastOutSlowIn,
      top: widget.topOffset,
      left: 0,
      right: 0,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Center(
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                margin: const EdgeInsets.symmetric(horizontal: 40),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E).withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(
                    color: accentColor.withValues(alpha: 0.4),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, color: accentColor, size: 14),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        widget.message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
