import 'package:application/app/theme/app_colors.dart';
import 'package:application/app/widgets/app_background.dart';
import 'package:application/app/widgets/app_button.dart';
import 'package:application/app/widgets/app_toast.dart';
import 'package:application/app/widgets/entrance_stagger.dart';
import 'package:application/app/widgets/settings_tile.dart';
import 'package:application/services/auth_api_client.dart';
import 'package:application/state/auth_controller.dart';
import 'package:application/state/cloud_controller.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
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

  Future<void> _pickBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _birthDate = picked);
  }

  Future<void> _handleUpdate() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isProcessing = true);

    // 1. Update local DB
    final success = await context.read<AuthController>().updateProfile(
          name: _nameController.text.trim(),
          surname: _surnameController.text.trim(),
          birthDate: _birthDate,
        );

    // 2. Sync with Cloud (Identity sync is allowed on all plans)
    if (success) {
      if (!mounted) return;
      await context.read<CloudController>().updateProfileCloud(
            name: _nameController.text.trim(),
            surname: _surnameController.text.trim(),
            birthDate: _birthDate,
          );
    }

    if (!mounted) return;
    setState(() => _isProcessing = false);
    
    AppToast.show(context, 'Profile updated and synced.', type: AppToastType.success);
  }

  Widget _buildReadOnlyField({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textFaint),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.textFaint,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                  ),
                ),
                Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityCard(AuthSession? session) {
    final hasKey = session?.wrappedDek != null && session?.wrappedDek != '';
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: hasKey
            ? AppColors.success.withValues(alpha: 0.05)
            : AppColors.danger.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: hasKey
              ? AppColors.success.withValues(alpha: 0.1)
              : AppColors.danger.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Icon(
            hasKey ? Icons.enhanced_encryption_rounded : Icons.no_encryption_gmailerrorred_rounded,
            color: hasKey ? AppColors.success : AppColors.danger,
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'End-to-End Encryption',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                Text(
                  hasKey ? 'Your personal data is safely encrypted.' : 'Security key missing. Decryption unavailable.',
                  style: TextStyle(
                    color: hasKey ? AppColors.textSecondary : AppColors.danger,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChangePasswordSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Security',
          style: TextStyle(
            color: AppColors.textFaint,
            fontWeight: FontWeight.w700,
            fontSize: 11,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        SettingsTile(
          title: 'Change Password',
          subtitle: 'Update your account password',
          icon: Icons.lock_outline_rounded,
          color: AppColors.gold,
          onTap: _showChangePasswordDialog,
        ),
      ],
    );
  }

  Future<void> _showChangePasswordDialog() async {
    final oldController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool loading = false;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Change Password'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: oldController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Old Password'),
                  validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: newController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'New Password'),
                  validator: (v) => (v == null || v.length < 8) ? 'Min 8 chars' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: confirmController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Confirm New Password'),
                  validator: (v) => v != newController.text ? 'Mismatch' : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: loading
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;
                      setDialogState(() => loading = true);
                      final cloud = context.read<CloudController>();
                      final success = await cloud.changePasswordCloud(
                        oldPassword: oldController.text,
                        newPassword: newController.text,
                      );
                      if (ctx.mounted) {
                        setDialogState(() => loading = false);
                        if (success) {
                          Navigator.pop(ctx);
                          if (context.mounted) AppToast.show(context, 'Password changed successfully.', type: AppToastType.success);
                        } else {
                          if (context.mounted) {
                            final msg = switch (cloud.errorCode) {
                              'invalid_credentials' => 'Old password incorrect.',
                              'network_error' => 'Server unreachable.',
                              _ => 'Error: ${cloud.errorCode ?? 'unknown'}',
                            };
                            AppToast.show(context, msg, type: AppToastType.error);
                          }
                        }
                      }
                    },
              child: loading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Change'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthController>().currentUser;
    final cloud = context.watch<CloudController>();
    final session = cloud.session;

    return Scaffold(
      appBar: AppBar(title: const Text('Account Details')),
      body: AppBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: ClampingScrollPhysics(),
            ),
            padding: const EdgeInsets.all(24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      EntranceStagger(
                        spacing: 16,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildSecurityCard(session),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: _buildReadOnlyField(
                                  label: 'Username',
                                  value: user?.username ?? '—',
                                  icon: Icons.alternate_email_rounded,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildReadOnlyField(
                                  label: 'Email',
                                  value: user?.email ?? session?.email ?? '—',
                                  icon: Icons.mail_outline_rounded,
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          TextFormField(
                            controller: _nameController,
                            style: const TextStyle(color: AppColors.textPrimary),
                            decoration: const InputDecoration(
                              labelText: 'First Name',
                              prefixIcon: Icon(Icons.badge_outlined, size: 20),
                            ),
                            validator: (v) =>
                                (v == null || v.isEmpty) ? 'Required' : null,
                          ),
                          TextFormField(
                            controller: _surnameController,
                            style: const TextStyle(color: AppColors.textPrimary),
                            decoration: const InputDecoration(
                              labelText: 'Last Name',
                              prefixIcon: Icon(Icons.badge_outlined, size: 20),
                            ),
                            validator: (v) =>
                                (v == null || v.isEmpty) ? 'Required' : null,
                          ),
                          InkWell(
                            onTap: _pickBirthDate,
                            borderRadius: BorderRadius.circular(24),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
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
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Birth Date',
                                        style: TextStyle(
                                          color: AppColors.textFaint,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        DateFormat('dd/MM/yyyy')
                                            .format(_birthDate),
                                        style: const TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  const Text(
                                    'Change',
                                    style: TextStyle(
                                      color: AppColors.accent,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          AppButton(
                            label: 'Update Profile',
                            icon: Icons.check_rounded,
                            isFullWidth: false,
                            onPressed: _isProcessing ? null : _handleUpdate,
                            isLoading: _isProcessing,
                          ),
                          const Divider(height: 32),
                          _buildChangePasswordSection(),
                        ],
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
