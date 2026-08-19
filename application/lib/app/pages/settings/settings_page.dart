import 'dart:convert';

import 'package:application/app/navigation/app_navigator.dart';
import 'package:application/app/pages/settings/cloud_section.dart';
import 'package:application/app/pages/settings/edit_profile_page.dart';
import 'package:application/app/theme/app_colors.dart';
import 'package:application/app/widgets/app_background.dart';
import 'package:application/app/widgets/app_toast.dart';
import 'package:application/app/widgets/entrance_stagger.dart';
import 'package:application/app/widgets/glass_card.dart';
import 'package:application/app/widgets/refresh_view.dart';
import 'package:application/app/widgets/section_header.dart';
import 'package:application/app/widgets/settings_tile.dart';
import 'package:application/state/auth_controller.dart';
import 'package:application/state/cloud_controller.dart';
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
  Future<void> _refresh() async {
    final auth = context.read<AuthController>();
    final moodController = context.read<MoodController>();
    await auth.refreshProfile();
    if (!mounted) return;
    final user = auth.currentUser;
    if (user != null) {
      await moodController.fetchMoodHistory(user.id);
    }
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
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        content: Text(message, style: const TextStyle(color: AppColors.textSecondary, height: 1.4)),
        actionsPadding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        actions: [
          Row(
            children: [
              // PRIMARY ACTION: SAFE & PROMINENT
              Expanded(
                flex: 2,
                child: FilledButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 4,
                    shadowColor: AppColors.accent.withValues(alpha: 0.3),
                  ),
                  child: const Text('Go Back', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                ),
              ),
              const SizedBox(width: 12),
              // SECONDARY ACTION: DISCRETE
              Expanded(
                flex: 1,
                child: TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  style: TextButton.styleFrom(
                    foregroundColor: isDestructive ? AppColors.danger : AppColors.textSecondary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(confirmLabel, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) await onConfirm();
  }

  void _showSnack(String message, {bool isError = false}) {
    if (!mounted) return;
    AppToast.show(
      context,
      message,
      type: isError ? AppToastType.error : AppToastType.success,
    );
  }

  Widget _buildPlanBadge(BuildContext context) {
    final cloud = context.watch<CloudController>();
    final session = cloud.session;
    if (session == null) return const SizedBox.shrink();

    final isPro = session.plan == 'pro';
    final isStandard = session.plan == 'standard';

    final Color color = isPro 
        ? AppColors.gold 
        : (isStandard ? AppColors.accent : AppColors.textFaint);
    
    final String label = isPro ? 'PRO' : (isStandard ? 'STANDARD' : 'FREE');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Future<void> _export(BuildContext context, CloudController cloud) async {
    final data = await cloud.exportCloudData();
    if (!mounted) return;
    if (data == null) {
      final msg = switch (cloud.errorCode) {
        'network_error' => 'Server unreachable.',
        'auth_error' || 'unauthorized' => 'Authentication failed.',
        _ => 'Export failed: ${cloud.errorCode ?? 'unknown'}',
      };
      _showSnack(msg, isError: true);
      return;
    }
    if (!mounted) return;
    final text = JsonEncoder.withIndent('  ').convert(data);
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Your data (JSON)'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: SelectableText(
              text.length > 4000 ? '${text.substring(0, 4000)}…' : text,
              style: const TextStyle(fontSize: 11),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthController>().currentUser;
    final cloud = context.watch<CloudController>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Profile')),
      body: AppBackground(
        child: RefreshView(
          onRefresh: _refresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: ClampingScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 160),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: EntranceStagger(
                  spacing: 24,
                  children: [
                    if (user != null)
                      GlassCard(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 28,
                              backgroundColor: AppColors.accent.withValues(
                                alpha: 0.14,
                              ),
                              child: Text(
                                user.name.isEmpty ? '?' : user.name[0].toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.accent,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          user.fullName.trim().isEmpty ? 'Set your name' : user.fullName,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      _buildPlanBadge(context),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    user.email ?? '@${user.username}',
                                    style: const TextStyle(
                                      color: AppColors.textFaint,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    
                    // 1. ACCOUNT & SECURITY
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionHeader(title: 'Account & Security'),
                        const SizedBox(height: 12),
                        GlassCard(
                          size: GlassCardSize.sm,
                          child: SettingsTile(
                            title: 'Account Details',
                            subtitle: 'Name, surname and password',
                            icon: Icons.person_outline_rounded,
                            color: AppColors.accent,
                            onTap: () => AppNavigator.push(context, const EditProfilePage()),
                          ),
                        ),
                      ],
                    ),

                    // 2. SERVICES & CLOUD
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionHeader(title: 'Services & Cloud'),
                        const SizedBox(height: 12),
                        const CloudSection(),
                      ],
                    ),

                    // 3. DATA & PRIVACY
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionHeader(title: 'Data & Privacy'),
                        const SizedBox(height: 12),
                        GlassCard(
                          size: GlassCardSize.sm,
                          child: Column(
                            children: [
                              SettingsTile(
                                title: 'Export Data (GDPR)',
                                subtitle: 'Download a copy of your journal',
                                icon: Icons.download_rounded,
                                color: AppColors.textSecondary,
                                onTap: () => _export(context, cloud),
                              ),
                              const Divider(indent: 64, height: 1),
                              SettingsTile(
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
                                      if (!mounted) return;
                                      final moodController = context.read<MoodController>();
                                      final cloudController = context.read<CloudController>();

                                      await moodController.clearHistoryBefore(user!.id, date);
                                      
                                      if (cloudController.isConnected) {
                                        await cloudController.wipeCloudData(before: date);
                                      }
                                      
                                      _showSnack('Selected history cleared.');
                                    },
                                  );
                                },
                              ),
                              const Divider(indent: 64, height: 1),
                              SettingsTile(
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
                                    if (!mounted) return;
                                    final moodController = context.read<MoodController>();
                                    final cloudController = context.read<CloudController>();

                                    await moodController.clearHistory(user!.id);
                                    
                                    if (cloudController.isConnected) {
                                      await cloudController.wipeCloudData();
                                    }

                                    _showSnack('Journal wiped clean.');
                                  },
                                ),
                              ),
                              const Divider(indent: 64, height: 1),
                              SettingsTile(
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
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    // 4. ACCESS (SYSTEM)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionHeader(title: 'Access'),
                        const SizedBox(height: 12),
                        GlassCard(
                          size: GlassCardSize.sm,
                          child: Column(
                            children: [
                              SettingsTile(
                                title: 'Log out',
                                subtitle: 'Sign out of your account',
                                icon: Icons.logout_rounded,
                                color: AppColors.textSecondary,
                                onTap: () => _confirmAction(
                                  title: 'Sign out?',
                                  message: 'Log out from your account?',
                                  onConfirm: () async {
                                    final navigator = Navigator.of(context);
                                    await context.read<CloudController>().logoutCloud();
                                    navigator.pushReplacementNamed('/login');
                                  },
                                ),
                              ),
                              const Divider(indent: 64, height: 1),
                              SettingsTile(
                                title: 'Delete account',
                                subtitle: 'Erase local data and cloud account',
                                icon: Icons.delete_forever_rounded,
                                color: AppColors.danger,
                                onTap: () => _confirmAction(
                                  title: 'Delete forever?',
                                  message:
                                      'This will erase the cloud account, all '
                                      'local data and your subscription. '
                                      'Irreversible.',
                                  isDestructive: true,
                                  confirmLabel: 'Delete',
                                  onConfirm: () async {
                                    final navigator = Navigator.of(context);
                                    final cloud = context.read<CloudController>();
                                    final success = await cloud.deleteCloudAccount();
                                    if (success) {
                                      navigator.pushReplacementNamed('/login');
                                    } else {
                                      if (mounted) {
                                        final msg = switch (cloud.errorCode) {
                                          'auth_error' ||
                                          'unauthorized' =>
                                            'Authentication failed. Please login again.',
                                          'network_error' =>
                                            'Server unreachable. Check your connection.',
                                          _ =>
                                            'Deletion failed: ${cloud.errorCode ?? 'unknown error'}',
                                        };
                                        _showSnack(msg, isError: true);
                                      }
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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
