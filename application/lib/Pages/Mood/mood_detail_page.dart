import 'package:application/DataBase/database.dart';
import 'package:application/Logic/login_controller.dart';
import 'package:application/Logic/mood_controller.dart';
import 'package:application/Utils/animations.dart';
import 'package:application/Utils/theme.dart';
import 'package:application/Widgets/glass_card.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class MoodDetailPage extends StatefulWidget {
  final EmotionData entry;
  const MoodDetailPage({super.key, required this.entry});
  @override
  State<MoodDetailPage> createState() => _MoodDetailPageState();
}

class _MoodDetailPageState extends State<MoodDetailPage> {
  late EmotionData _currentEntry;
  @override
  void initState() { super.initState(); _currentEntry = widget.entry; }

  @override
  Widget build(BuildContext context) {
    final moodController = context.read<MoodController>();
    final user = context.read<LoginController>().currentUser;
    final stateColor = AppTheme.getSmoothColor(_currentEntry.value.toDouble());

    return Scaffold(
      backgroundColor: AppTheme.backgroundBase,
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: Column(
          children: [
            SafeArea(bottom: false, child: Padding(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8), child: Row(children: [IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white), onPressed: () => Navigator.pop(context)), const Spacer(), const Text("NODE DETAILS", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Colors.white, letterSpacing: 2)), const Spacer(), IconButton(icon: const Icon(Icons.edit_note_rounded, color: Colors.white), onPressed: () => _showEditDialog(context)), IconButton(icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.terracottaError), onPressed: () => _confirmDelete(context, moodController, user?.id))]))),
            Expanded(child: SingleChildScrollView(padding: const EdgeInsets.fromLTRB(24, 12, 24, 40), physics: const BouncingScrollPhysics(), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              FadeInSlide(duration: 600, child: GlassCard(padding: const EdgeInsets.symmetric(vertical: 48), child: Center(child: Column(children: [Stack(alignment: Alignment.center, children: [Container(width: 140, height: 140, decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [BoxShadow(color: stateColor.withValues(alpha: 0.2), blurRadius: 50, spreadRadius: 5)])), Icon(AppIcons.getMoodIcon(_currentEntry.value), size: 80, color: Colors.white)]), const SizedBox(height: 24), Text(_getLabel(_currentEntry.value).toUpperCase(), style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: stateColor, letterSpacing: 2)), const SizedBox(height: 8), Text(DateFormat('EEEE, dd/MM/yyyy • HH:mm').format(_currentEntry.createdAt).toUpperCase(), style: const TextStyle(color: Colors.white30, fontWeight: FontWeight.w900, letterSpacing: 1, fontSize: 10))])))),
              const SizedBox(height: 40),
              if (_currentEntry.tags != null && _currentEntry.tags!.isNotEmpty) ...[
                _SectionHeader(title: "System Parameters", icon: Icons.memory_rounded),
                const SizedBox(height: 16),
                FadeInSlide(delay: 100, child: Wrap(spacing: 10, runSpacing: 10, children: _currentEntry.tags!.split(',').map((tagLabel) {
                  final tagData = moodController.availableTags.firstWhere((t) => t.label == tagLabel, orElse: () => MoodTagData(id: -1, label: tagLabel, emoji: 'tag'));
                  return Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withValues(alpha: 0.05))), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(AppIcons.fromString(tagData.emoji), size: 14, color: Colors.white70), const SizedBox(width: 8), Text(tagLabel.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 11))]));
                }).toList())),
                const SizedBox(height: 40),
              ],
              _SectionHeader(title: "Neural Reflection", icon: Icons.psychology_rounded),
              const SizedBox(height: 16),
              FadeInSlide(delay: 200, child: GlassCard(padding: const EdgeInsets.all(28), child: SizedBox(width: double.infinity, child: Text(_currentEntry.note?.isNotEmpty == true ? _currentEntry.note! : "Zero neural activity recorded.", style: TextStyle(color: _currentEntry.note?.isNotEmpty == true ? Colors.white : Colors.white24, fontSize: 16, height: 1.7, fontWeight: FontWeight.w500))))),
              const SizedBox(height: 100),
            ])))
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, MoodController controller, int? userId) async {
    final confirm = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(title: const Text("PURGE LOG?"), content: const Text("This system log will be permanently erased."), actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("ABORT")), ElevatedButton(onPressed: () => Navigator.pop(ctx, true), style: ElevatedButton.styleFrom(backgroundColor: AppTheme.terracottaError, foregroundColor: Colors.white), child: const Text("ERASE"))]));
    if (confirm == true && userId != null) {
      await controller.deleteEmotion(_currentEntry.id, userId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("System log erased."), behavior: SnackBarBehavior.floating));
        Navigator.pop(context);
      }
    }
  }

  void _showEditDialog(BuildContext context) {
    final moodController = context.read<MoodController>();
    final user = context.read<LoginController>().currentUser;
    if (user == null) return;
    final noteController = TextEditingController(text: _currentEntry.note);
    double tempValue = _currentEntry.value.toDouble();
    List<String> tempTags = _currentEntry.tags?.split(',').where((t) => t.isNotEmpty).toList() ?? [];
    showGeneralDialog(context: context, barrierDismissible: true, barrierLabel: "Edit Log", barrierColor: Colors.black.withValues(alpha: 0.8), transitionDuration: const Duration(milliseconds: 300), pageBuilder: (context, anim1, anim2) {
      return StatefulBuilder(builder: (context, setDialogState) {
        final stateColor = AppTheme.getSmoothColor(tempValue);
        return Scaffold(backgroundColor: Colors.transparent, body: Center(child: FadeInSlide(duration: 400, direction: const Offset(0, 30), child: Container(margin: const EdgeInsets.symmetric(horizontal: 24), child: GlassCard(padding: const EdgeInsets.all(28), child: Column(mainAxisSize: MainAxisSize.min, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("RE-CALIBRATION", style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white54, letterSpacing: 2, fontSize: 12)), IconButton(icon: const Icon(Icons.close_rounded, color: Colors.white24), onPressed: () => Navigator.pop(context))]),
          const SizedBox(height: 24),
          Stack(alignment: Alignment.center, children: [AnimatedContainer(duration: const Duration(milliseconds: 400), width: 100, height: 100, decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [BoxShadow(color: stateColor.withValues(alpha: 0.3), blurRadius: 40, spreadRadius: 5)])), Icon(AppIcons.getMoodIcon(tempValue.round()), size: 48, color: Colors.white)]),
          const SizedBox(height: 16), Text(_getLabel(tempValue.round()).toUpperCase(), style: TextStyle(color: stateColor, fontWeight: FontWeight.w900, letterSpacing: 3, fontSize: 16)),
          const SizedBox(height: 24), Slider(value: tempValue, min: 1, max: 10, divisions: 18, activeColor: stateColor, onChanged: (v) => setDialogState(() => tempValue = v)),
          const SizedBox(height: 24), Align(alignment: Alignment.centerLeft, child: const Text("TAGS", style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white24, letterSpacing: 1.5, fontSize: 10))),
          const SizedBox(height: 12), Wrap(spacing: 8, runSpacing: 8, children: moodController.availableTags.map((tag) {
            final isSelected = tempTags.contains(tag.label);
            return FilterChip(avatar: Icon(AppIcons.fromString(tag.emoji), size: 12, color: isSelected ? AppTheme.accent : Colors.white38), label: Text(tag.label.toUpperCase(), style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.white)), selected: isSelected, onSelected: (s) => setDialogState(() { if (s) tempTags.add(tag.label); else tempTags.remove(tag.label); }), backgroundColor: Colors.white.withValues(alpha: 0.03), selectedColor: AppTheme.accent.withValues(alpha: 0.2), checkmarkColor: AppTheme.accent, mouseCursor: SystemMouseCursors.click, shape: const ContinuousRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(24))), side: BorderSide(color: isSelected ? AppTheme.accent : Colors.white10));
          }).toList()),
          const SizedBox(height: 24), TextField(controller: noteController, maxLines: 3, style: const TextStyle(color: Colors.white, fontSize: 14), decoration: const InputDecoration(hintText: "Update neural notes...")),
          const SizedBox(height: 32), ElevatedButton(onPressed: () async {
            await moodController.updateEmotion(id: _currentEntry.id, userId: user.id, value: tempValue.round(), note: noteController.text, tags: tempTags, createdAt: _currentEntry.createdAt);
            setState(() { _currentEntry = _currentEntry.copyWith(value: tempValue.round(), note: Value(noteController.text), tags: Value(tempTags.isEmpty ? null : tempTags.join(','))); });
            if (mounted) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Neural log re-calibrated."), behavior: SnackBarBehavior.floating)); Navigator.pop(context); }
          }, child: const Text("SAVE RE-CALIBRATION")),
        ]))))));
      });
    }, transitionBuilder: (context, anim1, anim2, child) => FadeTransition(opacity: anim1, child: child));
  }

  String _getLabel(int value) {
    final labels = ['Dormant', 'Trace', 'Pulse', 'Core', 'Stasis', 'Flow', 'Active', 'Radiant', 'Vibrant', 'Zenith'];
    return labels[(value - 1).clamp(0, 9)];
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionHeader({required this.title, required this.icon});
  @override
  Widget build(BuildContext context) {
    return Row(children: [Icon(icon, size: 18, color: Colors.white30), const SizedBox(width: 10), Text(title.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white30, letterSpacing: 2, fontSize: 10))]);
  }
}
