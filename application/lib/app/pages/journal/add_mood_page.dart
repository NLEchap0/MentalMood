import 'package:application/app/theme/app_colors.dart';
import 'package:application/app/theme/app_icons.dart';
import 'package:application/app/theme/app_theme.dart';
import 'package:application/app/widgets/app_background.dart';
import 'package:application/app/widgets/app_button.dart';
import 'package:application/app/widgets/app_toast.dart';
import 'package:application/app/widgets/entrance_stagger.dart';
import 'package:application/app/widgets/glass_card.dart';
import 'package:application/app/widgets/refresh_view.dart';
import 'package:application/app/widgets/section_header.dart';
import 'package:application/domain/mood_labels.dart';
import 'package:application/services/auth_api_client.dart';
import 'package:application/services/sync_service.dart';
import 'package:application/state/auth_controller.dart';
import 'package:application/state/cloud_controller.dart';
import 'package:application/state/mood_controller.dart';
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

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    final user = context.read<AuthController>().currentUser;
    if (user != null) {
      await context.read<MoodController>().fetchMoodHistory(user.id);
    }
  }

  Future<void> _handleSave() async {
    final moodController = context.read<MoodController>();
    final user = context.read<AuthController>().currentUser;
    if (user == null) return;

    final note = _noteController.text.trim();
    final success = await moodController.saveMood(
      userId: user.id,
      value: _currentValue.round(),
      note: note.isEmpty ? null : note,
      tags: _selectedTags.isEmpty ? null : _selectedTags,
    );
    if (!mounted) return;
    if (success) {
      if (mounted) AppToast.show(context, 'Check-in saved. Well done.', type: AppToastType.success);
      // Trigger background sync
      _triggerSync();
      if (mounted) Navigator.pop(context);
    } else {
      if (mounted) AppToast.show(context, 'Could not save. Please try again.', type: AppToastType.error);
    }
  }

  Future<void> _triggerSync() async {
    final cloud = context.read<CloudController>();
    final session = cloud.session;
    final dek = await cloud.cloudDek();
    if (session == null || dek == null || !session.canSync) return;
    if (!mounted) return;
    final user = context.read<AuthController>().currentUser;
    if (user == null) return;

    // Fire and forget sync in background
    if (!mounted) return;
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
    final moodController = context.watch<MoodController>();
    final stateColor = AppTheme.getSmoothColor(_currentValue);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('New Check-in'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: AppBackground(
        child: SafeArea(
          child: RefreshView(
            onRefresh: _refresh,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: ClampingScrollPhysics(),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: EntranceStagger(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 40,
                    children: [
                      // The AppBar (extendBodyBehindAppBar) already clears the
                      // top area; keep only a small breathing gap.
                      const SizedBox(height: 8),
                      GlassCard(
                        padding: const EdgeInsets.symmetric(vertical: 48),
                        child: Column(
                          children: [
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 400),
                                  width: 160,
                                  height: 160,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: stateColor.withValues(alpha: 0.35),
                                      width: 1.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: stateColor.withValues(
                                          alpha: 0.25,
                                        ),
                                        blurRadius: 60,
                                        spreadRadius: 5,
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  AppIcons.getMoodIcon(_currentValue.round()),
                                  size: 72,
                                  color: Colors.white,
                                ),
                                Positioned(
                                  bottom: 12,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: stateColor.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      _currentValue.toStringAsFixed(1),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        color: stateColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),
                            AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 300),
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 4,
                                color: stateColor,
                              ),
                              child: Text(
                                moodLabelFor(
                                  _currentValue.round(),
                                ).toUpperCase(),
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'How are you feeling right now?',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 40),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              child: Slider(
                                value: _currentValue,
                                min: 1,
                                max: 10,
                                divisions: 18,
                                activeColor: stateColor,
                                onChanged: (v) =>
                                    setState(() => _currentValue = v),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SectionHeader(
                        title: 'Tags',
                        icon: Icons.sell_outlined,
                        trailing: _selectedTags.isEmpty
                            ? null
                            : Text(
                                '${_selectedTags.length} selected',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.accent,
                                ),
                              ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: moodController.availableTags.map((tag) {
                            final isSelected = _selectedTags.contains(
                              tag.label,
                            );
                            return FilterChip(
                              avatar: Icon(
                                AppIcons.fromString(tag.emoji),
                                size: 14,
                                color: isSelected
                                    ? AppColors.accent
                                    : AppColors.textSecondary,
                              ),
                              label: Text(
                                tag.label,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                              selected: isSelected,
                              onSelected: (selected) => setState(() {
                                if (selected) {
                                  _selectedTags.add(tag.label);
                                } else {
                                  _selectedTags.remove(tag.label);
                                }
                              }),
                              showCheckmark: false,
                            );
                          }).toList(),
                        ),
                      ),
                      const SectionHeader(
                        title: 'Notes',
                        icon: Icons.edit_outlined,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: TextField(
                          controller: _noteController,
                          maxLines: 3,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Anything on your mind?',
                          ),
                        ),
                      ),
                      AppButton(
                        label: 'Add Check-in',
                        icon: Icons.check_rounded,
                        onPressed: moodController.isLoading
                            ? null
                            : _handleSave,
                        isLoading: moodController.isLoading,
                      ),
                      const SizedBox(height: 100),
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
