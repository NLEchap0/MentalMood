import 'package:application/app/theme/app_colors.dart';
import 'package:application/app/theme/app_icons.dart';
import 'package:application/app/theme/app_theme.dart';
import 'package:application/app/widgets/app_background.dart';
import 'package:application/app/widgets/edit_mood_dialog.dart';
import 'package:application/app/widgets/entrance_stagger.dart';
import 'package:application/app/widgets/glass_card.dart';
import 'package:application/app/widgets/refresh_view.dart';
import 'package:application/app/widgets/section_header.dart';
import 'package:application/domain/models.dart';
import 'package:application/domain/mood_labels.dart';
import 'package:application/state/auth_controller.dart';
import 'package:application/state/mood_controller.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class MoodDetailPage extends StatefulWidget {
  final MoodEntry entry;
  const MoodDetailPage({super.key, required this.entry});

  @override
  State<MoodDetailPage> createState() => _MoodDetailPageState();
}

class _MoodDetailPageState extends State<MoodDetailPage> {
  late MoodEntry _currentEntry = widget.entry;

  /// Reloads history and keeps the displayed entry in sync.
  Future<void> _refresh() async {
    final user = context.read<AuthController>().currentUser;
    if (user != null) {
      await context.read<MoodController>().fetchMoodHistory(user.id);
      if (!mounted) return;
      final updated = context
          .read<MoodController>()
          .moodHistory
          .where((e) => e.id == _currentEntry.id)
          .firstOrNull;
      if (updated != null) setState(() => _currentEntry = updated);
    }
  }

  @override
  Widget build(BuildContext context) {
    final moodController = context.read<MoodController>();
    final user = context.read<AuthController>().currentUser;
    final stateColor = AppTheme.getSmoothColor(_currentEntry.value.toDouble());

    return Scaffold(
      backgroundColor: AppColors.backgroundBase,
      appBar: AppBar(
        title: const Text('Entry details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_note_rounded),
            onPressed: () {
              final controller = context.read<MoodController>();
              showEditMoodDialog(context, _currentEntry).then((_) {
                if (!mounted) return;
                final updated = controller.moodHistory
                    .where((e) => e.id == _currentEntry.id)
                    .firstOrNull;
                if (updated != null) setState(() => _currentEntry = updated);
              });
            },
            tooltip: 'Edit entry',
          ),
          IconButton(
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: AppColors.danger,
            ),
            onPressed: () => _confirmDelete(moodController, user?.id),
            tooltip: 'Delete entry',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: AppBackground(
        child: SafeArea(
          top: false,
          child: RefreshView(
            onRefresh: _refresh,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: EntranceStagger(
                    children: [
                      GlassCard(
                        size: GlassCardSize.lg,
                        padding: const EdgeInsets.symmetric(vertical: 48),
                        child: Column(
                          children: [
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: 140,
                                  height: 140,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: stateColor.withValues(
                                          alpha: 0.2,
                                        ),
                                        blurRadius: 50,
                                        spreadRadius: 5,
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  AppIcons.getMoodIcon(_currentEntry.value),
                                  size: 80,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            Text(
                              moodLabelFor(_currentEntry.value).toUpperCase(),
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 2,
                                color: stateColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              DateFormat(
                                'EEEE, dd/MM/yyyy • HH:mm',
                              ).format(_currentEntry.createdAt).toUpperCase(),
                              style: const TextStyle(
                                color: AppColors.textFaint,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_currentEntry.tags.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SectionHeader(
                              title: 'Tags',
                              icon: Icons.sell_outlined,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: _currentEntry.tags.map((tagLabel) {
                                  final tag = moodController.availableTags
                                      .where((t) => t.label == tagLabel)
                                      .firstOrNull;
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.05,
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: Colors.white.withValues(
                                          alpha: 0.08,
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          AppIcons.fromString(
                                            tag?.emoji ?? 'tag',
                                          ),
                                          size: 14,
                                          color: AppColors.textSecondary,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          tagLabel,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.textPrimary,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      const SectionHeader(
                        title: 'Notes',
                        icon: Icons.edit_outlined,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: GlassCard(
                          size: GlassCardSize.sm,
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            _currentEntry.hasNote
                                ? _currentEntry.note!
                                : 'No notes for this entry.',
                            style: TextStyle(
                              color: _currentEntry.hasNote
                                  ? AppColors.textPrimary
                                  : AppColors.textFaint,
                              fontSize: 15,
                              height: 1.7,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 60),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(MoodController controller, int? userId) async {
    if (userId == null) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete entry?'),
        content: const Text('This check-in will be permanently removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    await controller.deleteEmotion(_currentEntry.id, userId);
    messenger.showSnackBar(const SnackBar(content: Text('Entry deleted.')));
    navigator.pop();
  }
}
