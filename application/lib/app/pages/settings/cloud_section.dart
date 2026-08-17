import 'dart:convert';

import 'package:application/app/pages/settings/subscription_page.dart';
import 'package:application/app/theme/app_colors.dart';
import 'package:application/app/widgets/app_button.dart';
import 'package:application/app/widgets/glass_card.dart';
import 'package:application/services/auth_api_client.dart';
import 'package:application/services/sync_service.dart';
import 'package:application/state/auth_controller.dart';
import 'package:application/state/cloud_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Sezione "Cloud & AI": login/register verso l'API, stato piano,
/// consenso AI, sincronizzazione ed export dei dati.
class CloudSection extends StatefulWidget {
  const CloudSection({super.key});

  @override
  State<CloudSection> createState() => _CloudSectionState();
}

class _CloudSectionState extends State<CloudSection> {
  bool _syncing = false;

  @override
  Widget build(BuildContext context) {
    final cloud = context.watch<CloudController>();
    final session = cloud.session;

    return GlassCard(
      size: GlassCardSize.sm,
      child: Column(
        children: [
          if (session == null) ..._buildNotConnected(context, cloud),
          if (session != null) ..._buildConnected(context, cloud),
        ],
      ),
    );
  }

  List<Widget> _buildNotConnected(BuildContext context, CloudController cloud) {
    return [
      _Row(
        title: 'Cloud & AI',
        subtitle: 'Backup criptato, sync e funzioni AI',
        icon: Icons.cloud_outlined,
        color: AppColors.accent,
        onTap: () => _showAccountSheet(context, cloud),
      ),
      const Divider(indent: 64),
      _Row(
        title: 'Connect your account',
        subtitle: 'Login or register on the cloud',
        icon: Icons.login_rounded,
        color: AppColors.success,
        onTap: () => _showAccountSheet(context, cloud),
      ),
      if (cloud.isLoading)
        const Padding(
          padding: EdgeInsets.all(12),
          child: Center(
            child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
      if (cloud.errorCode != null)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            cloud.errorCode == 'network_error'
                ? 'Server unreachable — check that the API is running.'
                : 'Error: ${cloud.errorCode}',
            style: const TextStyle(color: AppColors.danger, fontSize: 12),
          ),
        ),
    ];
  }

  List<Widget> _buildConnected(BuildContext context, CloudController cloud) {
    final session = cloud.session!;
    final sub = cloud.subscription;

    return [
      _Row(
        title: 'Cloud connected',
        subtitle: '@${session.username} · ${session.plan} plan',
        icon: Icons.cloud_done_outlined,
        color: AppColors.success,
        onTap: () => _showAccountSheet(context, cloud),
      ),
      const Divider(indent: 64),
      _Row(
        title: 'Subscription',
        subtitle: sub == null
            ? 'Tap to manage your plan'
            : '${sub.plan} · ${sub.status} · ${sub.aiCredits} AI credits',
        icon: Icons.workspace_premium_outlined,
        color: AppColors.gold,
        onTap: () async {
          await cloud.refreshSubscription();
          if (context.mounted) {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const SubscriptionPage(),
              ),
            );
          }
        },
      ),
      const Divider(indent: 64),
      SwitchListTile(
        value: cloud.consentEnabled,
        onChanged: cloud.isLoading ? null : (v) => cloud.setAiConsent(v),
        title: const Text(
          'AI consent',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
        subtitle: const Text(
          'Allow the AI to analyse your data for insights',
          style: TextStyle(color: AppColors.textFaint, fontSize: 11.5),
        ),
        secondary: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.smart_toy_outlined,
              color: AppColors.accent, size: 19),
        ),
      ),
      const Divider(indent: 64),
      _Row(
        title: 'Sync now',
        subtitle: cloud.lastSyncResult ?? 'Push and pull encrypted data',
        icon: Icons.sync_rounded,
        color: AppColors.accent,
        onTap: _syncing ? null : () => _runSync(context, cloud),
      ),
      const Divider(indent: 64),
      _Row(
        title: 'Export data (GDPR)',
        subtitle: 'Download a JSON copy of your data',
        icon: Icons.download_rounded,
        color: AppColors.textSecondary,
        onTap: () => _export(context, cloud),
      ),
      const Divider(indent: 64),
      _Row(
        title: 'Delete cloud account',
        subtitle: 'Erase the account and all cloud data',
        icon: Icons.person_remove_rounded,
        color: AppColors.danger,
        onTap: () => _confirmDeleteCloud(context, cloud),
      ),
      if (cloud.errorCode != null)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Error: ${cloud.errorCode}',
            style: const TextStyle(color: AppColors.danger, fontSize: 12),
          ),
        ),
    ];
  }

  Future<void> _runSync(BuildContext context, CloudController cloud) async {
    setState(() => _syncing = true);
    final session = cloud.session;
    final dek = await cloud.cloudDek();
    if (!mounted) return;
    if (session == null || dek == null) {
      cloud.setSyncResult('Missing session or key');
      if (mounted) setState(() => _syncing = false);
      return;
    }
    final sync = this.context.read<SyncService>();
    final userId = this.context.read<AuthController>().currentUser?.id ?? 0;
    final ok = await sync.sync(
      userId: userId,
      credentials: SyncCredentials(
        accessToken: session.accessToken,
        syncKey: session.syncKey,
        dek: dek,
      ),
      // Il sync concatena /sync: passiamo l'URL base senza index.php
      // e il client lo gestisce (HttpSyncClient usa apiEndpoint).
      baseUrl: apiBaseUrl().replaceAll(RegExp(r'/+$'), ''),
    );
    cloud.setSyncResult(ok
        ? 'Synced ${sync.lastSyncAt?.toIso8601String() ?? ''}'
        : 'Sync failed: ${sync.errorCode ?? 'unknown'}');
    if (mounted) setState(() => _syncing = false);
  }

  Future<void> _export(BuildContext context, CloudController cloud) async {
    final data = await cloud.exportCloudData();
    if (!mounted) return;
    if (data == null) {
      _snack(this.context, 'Export failed: ${cloud.errorCode}');
      return;
    }
    final text = const JsonEncoder.withIndent('  ').convert(data);
    await showDialog<void>(
      context: this.context,
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

  Future<void> _confirmDeleteCloud(
    BuildContext context,
    CloudController cloud,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete cloud account?'),
        content: const Text(
            'This erases the account and all cloud data. Irreversible.'),
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
    if (confirmed == true) {
      final ok = await cloud.deleteCloudAccount();
      if (mounted) {
        _snack(this.context, ok ? 'Cloud account deleted.' : 'Delete failed.');
      }
    }
  }

  Future<void> _showAccountSheet(
    BuildContext context,
    CloudController cloud,
  ) async {
    final username = TextEditingController();
    final email = TextEditingController();
    final password = TextEditingController();
    var mode = 'login'; // 'login' | 'register'
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 32,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                mode == 'login' ? 'Connect to cloud' : 'Create cloud account',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: username,
                decoration: const InputDecoration(labelText: 'Username'),
              ),
              const SizedBox(height: 12),
              if (mode == 'register') ...[
                TextField(
                  controller: email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                const SizedBox(height: 12),
              ],
              TextField(
                controller: password,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password'),
              ),
              if (cloud.errorCode != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Error: ${cloud.errorCode}',
                  style: const TextStyle(color: AppColors.danger, fontSize: 12),
                ),
              ],
              const SizedBox(height: 20),
              AppButton(
                label: mode == 'login' ? 'Login' : 'Register',
                isLoading: cloud.isLoading,
                onPressed: () async {
                  final ok = mode == 'login'
                      ? await cloud.loginCloud(
                          username: username.text.trim(),
                          password: password.text,
                        )
                      : await cloud.registerCloud(
                          username: username.text.trim(),
                          email: email.text.trim(),
                          password: password.text,
                        );
                  if (ok && ctx.mounted) {
                    Navigator.pop(ctx);
                  } else {
                    setSheetState(() {});
                  }
                },
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => setSheetState(
                  () => mode = mode == 'login' ? 'register' : 'login',
                ),
                child: Text(
                  mode == 'login'
                      ? 'No account? Register here'
                      : 'Already have an account? Login',
                  style: const TextStyle(color: AppColors.accent),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _snack(BuildContext context, String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _Row extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _Row({
    required this.title,
    this.subtitle,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
        trailing: onTap == null
            ? null
            : const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textFaint,
                size: 18,
              ),
      ),
    );
  }
}
