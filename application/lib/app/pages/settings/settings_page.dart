import 'package:application/app/pages/settings/cloud_section.dart';
import 'package:application/app/pages/settings/tools_section.dart';
import 'package:application/app/theme/app_colors.dart';
import 'package:application/app/widgets/app_background.dart';
import 'package:application/app/widgets/app_button.dart';
import 'package:application/app/widgets/entrance_stagger.dart';
import 'package:application/app/widgets/glass_card.dart';
import 'package:application/app/widgets/refresh_view.dart';
import 'package:application/app/widgets/section_header.dart';
import 'package:application/state/auth_controller.dart';
import 'package:application/state/mood_controller.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _surnameController;
  late DateTime _birthDate;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthController>().currentUser;
    _nameController = TextEditingController(text: user?.name ?? '');
    _surnameController = TextEditingController(text: user?.surname ?? '');
    _birthDate = user?.birthDate ?? DateTime(2000);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    final auth = context.read<AuthController>();
    final moodController = context.read<MoodController>();
    await auth.refreshProfile();
    final user = auth.currentUser;
    if (user != null) {
      await moodController.fetchMoodHistory(user.id);
    }
  }

  Future<void> _handleUpdate() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isProcessing = true);
    await context.read<AuthController>().updateProfile(
      name: _nameController.text.trim(),
      surname: _surnameController.text.trim(),
      birthDate: _birthDate,
    );
    if (!mounted) return;
    setState(() => _isProcessing = false);
    _showSnack('Profile updated.');
  }

  Future<void> _confirmAction({
    required String title,
    required String message,
    required Future<void> Function() onConfirm,
    bool isDestructive = false,
    String confirmLabel = 'Confirm',
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDestructive
                  ? AppColors.danger
                  : AppColors.accent,
              foregroundColor: Colors.white,
            ),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) await onConfirm();
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _pickBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _birthDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthController>().currentUser;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Profile')),
      body: AppBackground(
        child: RefreshView(
          onRefresh: _refresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 160),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: EntranceStagger(
                  spacing: 40,
                  children: [
                    if (user != null)
                      GlassCard(
                        padding: const EdgeInsets.all(24),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 34,
                              backgroundColor: AppColors.accent.withValues(
                                alpha: 0.14,
                              ),
                              child: Text(
                                user.name[0].toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.accent,
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user.fullName,
                                    style: const TextStyle(
                                      fontSize: 21,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    '@MentalMood member',
                                    style: TextStyle(
                                      color: AppColors.textFaint,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SectionHeader(title: 'Personal Info'),
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _nameController,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                              ),
                              decoration: const InputDecoration(
                                labelText: 'Name',
                              ),
                              validator: (v) =>
                                  (v == null || v.isEmpty) ? 'Required' : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _surnameController,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                              ),
                              decoration: const InputDecoration(
                                labelText: 'Surname',
                              ),
                              validator: (v) =>
                                  (v == null || v.isEmpty) ? 'Required' : null,
                            ),
                            const SizedBox(height: 16),
                            InkWell(
                              onTap: _pickBirthDate,
                              borderRadius: BorderRadius.circular(24),
                              mouseCursor: SystemMouseCursors.click,
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.06),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.cake_outlined,
                                      color: AppColors.textSecondary,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      DateFormat(
                                        'dd/MM/yyyy',
                                      ).format(_birthDate),
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const Spacer(),
                                    const Text(
                                      'Change',
                                      style: TextStyle(
                                        color: AppColors.accent,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            AppButton(
                              label: 'Save Changes',
                              onPressed: _handleUpdate,
                              isLoading: _isProcessing,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SectionHeader(title: 'Data'),
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: GlassCard(
                        size: GlassCardSize.sm,
                        child: Column(
                          children: [
                            _Tile(
                              title: 'Generate sample data',
                              subtitle: 'Add 60 days of test entries',
                              icon: Icons.storage_rounded,
                              color: AppColors.gold,
                              onTap: () => _confirmAction(
                                title: 'Seed sample data?',
                                message:
                                    'Add random entries for testing purposes.',
                                onConfirm: () async {
                                  await context
                                      .read<MoodController>()
                                      .seedMockData(user!.id);
                                  _showSnack('Sample data generated.');
                                },
                              ),
                            ),
                            const Divider(indent: 64),
                            _Tile(
                              title: 'Clean up history',
                              subtitle: 'Delete entries before a date',
                              icon: Icons.history_rounded,
                              color: AppColors.success,
                              onTap: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now().subtract(
                                    const Duration(days: 30),
                                  ),
                                  firstDate: DateTime(1900),
                                  lastDate: DateTime.now(),
                                );
                                if (date == null || !mounted) return;
                                await _confirmAction(
                                  title: 'Delete entries?',
                                  message:
                                      'Delete all check-ins before ${DateFormat('dd/MM/yyyy').format(date)}?',
                                  isDestructive: true,
                                  confirmLabel: 'Delete',
                                  onConfirm: () async {
                                    await context
                                        .read<MoodController>()
                                        .clearHistoryBefore(user!.id, date);
                                    _showSnack('Selected history cleared.');
                                  },
                                );
                              },
                            ),
                            const Divider(indent: 64),
                            _Tile(
                              title: 'Wipe all data',
                              subtitle: 'Permanently delete every entry',
                              icon: Icons.delete_sweep_rounded,
                              color: AppColors.danger,
                              onTap: () => _confirmAction(
                                title: 'Clear journal?',
                                message:
                                    'Every entry will be deleted permanently.',
                                isDestructive: true,
                                confirmLabel: 'Delete',
                                onConfirm: () async {
                                  await context
                                      .read<MoodController>()
                                      .clearHistory(user!.id);
                                  _showSnack('Journal wiped clean.');
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SectionHeader(title: 'Cloud & AI'),
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: const CloudSection(),
                    ),
                    const SizedBox(height: 40),
                    const SectionHeader(title: 'Tools & AI'),
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: const ToolsSection(),
                    ),
                    const SizedBox(height: 40),
                    const SectionHeader(title: 'Account'),
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: GlassCard(
                        size: GlassCardSize.sm,
                        child: Column(
                          children: [
                            _Tile(
                              title: 'Log out',
                              icon: Icons.logout_rounded,
                              color: AppColors.textSecondary,
                              onTap: () => _confirmAction(
                                title: 'Sign out?',
                                message: 'Log out from your account?',
                                onConfirm: () async {
                                  final navigator = Navigator.of(context);
                                  await context.read<AuthController>().logout();
                                  navigator.pushReplacementNamed('/login');
                                },
                              ),
                            ),
                            const Divider(indent: 64),
                            _Tile(
                              title: 'Delete account',
                              subtitle: 'Erase account and all data',
                              icon: Icons.person_remove_rounded,
                              color: AppColors.danger,
                              onTap: () => _confirmAction(
                                title: 'Delete forever?',
                                message:
                                    'This will erase your account and all data. Irreversible.',
                                isDestructive: true,
                                confirmLabel: 'Delete',
                                onConfirm: () async {
                                  final navigator = Navigator.of(context);
                                  await context
                                      .read<AuthController>()
                                      .deleteAccount();
                                  navigator.pushReplacementNamed('/login');
                                },
                              ),
                            ),
                          ],
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

class _Tile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _Tile({
    required this.title,
    this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // A transparent Material lets the ListTile paint its ink splashes
    // over the glass card background.
    return Material(
      type: MaterialType.transparency,
      child: ListTile(
        onTap: onTap,
        minVerticalPadding: 10,
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 19),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
        subtitle: subtitle == null
            ? null
            : Text(
                subtitle!,
                style: const TextStyle(
                  color: AppColors.textFaint,
                  fontSize: 11.5,
                ),
              ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: AppColors.textFaint,
          size: 18,
        ),
      ),
    );
  }
}
