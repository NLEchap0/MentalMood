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

/// "Cloud & AI" section: login/register with the API, plan state,
/// AI consent, data synchronization, and export.
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
        subtitle: 'Encrypted backup, sync and AI features',
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
        title: 'Account',
        subtitle: '@${session.username} · ${session.plan} plan',
        icon: Icons.person_outline_rounded,
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
      if (sub != null && sub.plan == 'pro') ...[
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
      ],
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
      // Sync concatenates /sync: we pass the base URL without index.php
      // and the client handles it (HttpSyncClient uses apiEndpoint).
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

  Future<void> _showAccountSheet(
    BuildContext context,
    CloudController cloud,
  ) async {
    final username = TextEditingController();
    final email = TextEditingController();
    final name = TextEditingController();
    final surname = TextEditingController();
    final password = TextEditingController();
    DateTime? birthDate;
    String? birthDateError;
    var mode = 'login'; // 'login' | 'register'

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (stfCtx, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(stfCtx).viewInsets.bottom + 32,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      mode == 'login'
                          ? 'Connect to cloud'
                          : 'Create cloud account',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: username,
                      decoration: InputDecoration(
                        labelText: mode == 'login'
                            ? 'Username or Email'
                            : 'Username',
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (mode == 'register') ...[
                      TextField(
                        controller: email,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(labelText: 'Email'),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: name,
                              decoration:
                                  const InputDecoration(labelText: 'Name'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: surname,
                              decoration:
                                  const InputDecoration(labelText: 'Surname'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: stfCtx,
                            initialDate: birthDate ?? DateTime(2000),
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) {
                            setSheetState(() {
                              birthDate = picked;
                              birthDateError = null;
                            });
                          }
                        },
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Birth Date',
                            errorText: birthDateError == null
                                ? null
                                : 'Required',
                          ),
                          child: Text(
                            birthDate == null
                                ? 'Select your birth date'
                                : "${birthDate!.day}/${birthDate!.month}/${birthDate!.year}",
                            style: TextStyle(
                              color: birthDate == null
                                  ? AppColors.textSecondary
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ),
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
                        switch (cloud.errorCode) {
                          'network_error' =>
                            'Server unreachable. Check your connection.',
                          'conflict' ||
                          'username_taken' =>
                            'Username or email already taken.',
                          'auth_error' ||
                          'invalid_credentials' =>
                            'Invalid username or password.',
                          _ => 'Error: ${cloud.errorCode}',
                        },
                        style: const TextStyle(
                            color: AppColors.danger, fontSize: 12),
                      ),
                    ],
                    const SizedBox(height: 20),
                    AppButton(
                      label: mode == 'login' ? 'Login' : 'Register',
                      isLoading: cloud.isLoading,
                      onPressed: () async {
                        if (mode == 'register') {
                          if (name.text.trim().isEmpty ||
                              surname.text.trim().isEmpty ||
                              email.text.trim().isEmpty ||
                              username.text.trim().isEmpty ||
                              password.text.isEmpty) {
                            setSheetState(() => birthDateError = 'fill');
                            return;
                          }
                          if (birthDate == null) {
                            setSheetState(() => birthDateError = 'date');
                            return;
                          }
                        }
                        bool ok;
                        if (mode == 'login') {
                          ok = await cloud.loginCloud(
                            identifier: username.text.trim(),
                            password: password.text,
                          );
                        } else {
                          ok = await cloud.registerCloud(
                            username: username.text.trim(),
                            email: email.text.trim(),
                            password: password.text,
                            name: name.text.trim(),
                            surname: surname.text.trim(),
                            birthDate: birthDate!,
                          );
                        }
                        if (ok && stfCtx.mounted) {
                          Navigator.pop(stfCtx);
                        } else {
                          setSheetState(() {});
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => setSheetState(() {
                        mode = mode == 'login' ? 'register' : 'login';
                      }),
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
            );
          },
        );
      },
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
