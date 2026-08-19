import 'package:application/app/theme/app_colors.dart';
import 'package:application/app/theme/app_icons.dart';
import 'package:application/app/theme/app_theme.dart';
import 'package:application/app/theme/animations.dart';
import 'package:application/app/widgets/app_background.dart';
import 'package:application/app/widgets/app_button.dart';
import 'package:application/app/widgets/app_toast.dart';
import 'package:application/app/widgets/glass_card.dart';
import 'package:application/domain/models.dart';
import 'package:application/domain/mood_labels.dart';
import 'package:application/services/auth_api_client.dart';
import 'package:application/services/sync_service.dart';
import 'package:application/state/auth_controller.dart';
import 'package:application/state/cloud_controller.dart';
import 'package:application/state/mood_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Modal editor for an existing entry (value, tags, note).
Future<void> showEditMoodDialog(BuildContext context, MoodEntry entry) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Edit entry',
    barrierColor: Colors.black.withValues(alpha: 0.7),
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, anim1, anim2) => EditMoodDialog(entry: entry),
    transitionBuilder: (context, anim, secondary, child) =>
        FadeTransition(opacity: anim, child: child),
  );
}

class EditMoodDialog extends StatefulWidget {
  final MoodEntry entry;
  const EditMoodDialog({super.key, required this.entry});

  @override
  State<EditMoodDialog> createState() => _EditMoodDialogState();
}

class _EditMoodDialogState extends State<EditMoodDialog> {
  late double _tempValue = widget.entry.value.toDouble();
  late final List<String> _tempTags = List.of(widget.entry.tags);
  late final TextEditingController _noteController = TextEditingController(
    text: widget.entry.note,
  );

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final moodController = context.read<MoodController>();
    final user = context.read<AuthController>().currentUser;
    if (user == null) return;

    final note = _noteController.text.trim();
    final success = await moodController.updateEmotion(
      id: widget.entry.id,
      userId: user.id,
      value: _tempValue.round(),
      note: note.isEmpty ? null : note,
      tags: _tempTags,
      createdAt: widget.entry.createdAt,
    );
    if (!mounted) return;
    if (success) {
      AppToast.show(
        context,
        'Entry updated.',
        type: AppToastType.success,
      );
      // Trigger background sync
      _triggerSync();
      Navigator.pop(context);
    } else {
      AppToast.show(
        context,
        'Could not update. Please try again.',
        type: AppToastType.error,
      );
    }
  }

  Future<void> _triggerSync() async {
    final cloud = context.read<CloudController>();
    final session = cloud.session;
    final dek = await cloud.cloudDek();
    if (session == null || dek == null || !session.canSync) return;
    final user = context.read<AuthController>().currentUser;
    if (user == null) return;

    // Fire and forget sync in background
    context.read<SyncService>().sync(
          userId: user.id,
          credentials: SyncCredentials(
            accessToken: session.accessToken,
            syncKey: session.syncKey,
            dek: dek,
          ),
          baseUrl: apiBaseUrl().replaceAll(RegExp(r'/+$'), ''),
        );
  }

  @override
  Widget build(BuildContext context) {
    final stateColor = AppTheme.getSmoothColor(_tempValue);
    final moodController = context.watch<MoodController>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: Center(
          child: FadeInSlide(
            duration: const Duration(milliseconds: 400),
            direction: const Offset(0, 30),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: GlassCard(
                  size: GlassCardSize.lg,
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'EDIT ENTRY',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: AppColors.textSecondary,
                              letterSpacing: 1.5,
                              fontSize: 12,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.close_rounded,
                              color: AppColors.textSecondary,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Column(
                          children: [
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 400),
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: stateColor.withValues(
                                          alpha: 0.25,
                                        ),
                                        blurRadius: 40,
                                        spreadRadius: 5,
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  AppIcons.getMoodIcon(_tempValue.round()),
                                  size: 48,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              moodLabelFor(_tempValue.round()).toUpperCase(),
                              style: TextStyle(
                                color: stateColor,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 3,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Slider(
                        value: _tempValue,
                        min: 1,
                        max: 10,
                        divisions: 18,
                        activeColor: stateColor,
                        onChanged: (v) => setState(() => _tempValue = v),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'TAGS',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                          letterSpacing: 1.5,
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: moodController.availableTags.map((tag) {
                          final isSelected = _tempTags.contains(tag.label);
                          return FilterChip(
                            avatar: Icon(
                              AppIcons.fromString(tag.emoji),
                              size: 12,
                              color: isSelected
                                  ? AppColors.accent
                                  : AppColors.textSecondary,
                            ),
                            label: Text(
                              tag.label,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            selected: isSelected,
                            onSelected: (s) => setState(() {
                              if (s) {
                                _tempTags.add(tag.label);
                              } else {
                                _tempTags.remove(tag.label);
                              }
                            }),
                            showCheckmark: false,
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _noteController,
                        maxLines: 3,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Update notes...',
                        ),
                      ),
                      const SizedBox(height: 28),
                      AppButton(
                        label: 'Save Changes',
                        icon: Icons.check_rounded,
                        onPressed: _save,
                      ),
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
}
