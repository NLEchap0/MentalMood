import 'package:application/Logic/login_controller.dart';
import 'package:application/Logic/mood_controller.dart';
import 'package:application/Utils/animations.dart';
import 'package:application/Utils/theme.dart';
import 'package:application/Widgets/glass_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddMoodPage extends StatefulWidget {
  const AddMoodPage({super.key});

  @override
  State<AddMoodPage> createState() => _AddMoodPageState();
}

class _AddMoodPageState extends State<AddMoodPage> {
  double _currentValue = 5.5;
  final TextEditingController _noteController = TextEditingController();
  final List<String> _selectedTags = [];

  final List<String> _labels = ['DORMANT', 'TRACE', 'PULSE', 'CORE', 'STASIS', 'FLOW', 'ACTIVE', 'RADIANT', 'VIBRANT', 'ZENITH'];

  @override
  Widget build(BuildContext context) {
    final moodController = context.watch<MoodController>();
    final user = context.read<LoginController>().currentUser;
    final stateColor = AppTheme.getSmoothColor(_currentValue);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("SYSTEM CHECK-IN"),
        leading: IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(context)),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 120),
              FadeInSlide(
                child: GlassCard(
                  padding: const EdgeInsets.symmetric(vertical: 60),
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 400),
                            width: 160, height: 160,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: stateColor.withValues(alpha: 0.4), width: 1),
                              boxShadow: [BoxShadow(color: stateColor.withValues(alpha: 0.3), blurRadius: 60, spreadRadius: 5)],
                            ),
                          ),
                          Icon(AppIcons.getMoodIcon(_currentValue.round()), size: 72, color: Colors.white),
                          Positioned(bottom: 12, child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)), child: Text(_currentValue.toStringAsFixed(1), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.white70)))),
                        ],
                      ),
                      const SizedBox(height: 32),
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 300),
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: stateColor, letterSpacing: 4, shadows: [Shadow(color: stateColor.withValues(alpha: 0.5), blurRadius: 15)]),
                        child: Text(_labels[(_currentValue.round() - 1).clamp(0, 9)]),
                      ),
                      const SizedBox(height: 48),
                      Slider(
                        value: _currentValue, min: 1, max: 10, divisions: 18,
                        onChanged: (v) => setState(() => _currentValue = v),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
              _Section(
                title: "Internal Parameters",
                child: Wrap(
                  spacing: 10, runSpacing: 10,
                  children: moodController.availableTags.map((tag) {
                    final isSelected = _selectedTags.contains(tag.label);
                    return FilterChip(
                      avatar: Icon(AppIcons.fromString(tag.emoji), size: 14, color: isSelected ? AppTheme.accent : Colors.white38),
                      label: Text(tag.label.toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1)),
                      selected: isSelected,
                      onSelected: (selected) => setState(() { if (selected) _selectedTags.add(tag.label); else _selectedTags.remove(tag.label); }),
                      backgroundColor: Colors.white.withValues(alpha: 0.03),
                      selectedColor: AppTheme.accent.withValues(alpha: 0.15),
                      checkmarkColor: AppTheme.accent,
                      mouseCursor: SystemMouseCursors.click,
                      shape: const ContinuousRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(24))),
                      side: BorderSide(color: isSelected ? AppTheme.accent : Colors.white.withValues(alpha: 0.05)),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 32),
              _Section(
                title: "Log Data",
                child: TextField(
                  controller: _noteController,
                  maxLines: 3,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 15),
                  decoration: const InputDecoration(hintText: "Enter system reflections...", contentPadding: EdgeInsets.all(20)),
                ),
              ),
              const SizedBox(height: 48),
              FadeInSlide(
                delay: 200,
                child: ElevatedButton(
                  onPressed: moodController.isLoading ? null : () async {
                    if (user == null) return;
                    final success = await moodController.saveMood(userId: user.id, value: _currentValue.round(), note: _noteController.text.isNotEmpty ? _noteController.text : null, tags: _selectedTags.isNotEmpty ? _selectedTags : null);
                    if (success && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Neural state synchronized successfully."), behavior: SnackBarBehavior.floating));
                      Navigator.pop(context);
                    }
                  },
                  child: moodController.isLoading ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2)) : const Text("SYNC DATA"),
                ),
              ),
              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  const _Section({required this.title, required this.child});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white24, letterSpacing: 2, fontSize: 10)),
        const SizedBox(height: 16),
        child,
      ],
    );
  }
}
