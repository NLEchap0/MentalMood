import 'package:application/app/theme/app_colors.dart';
import 'package:application/app/widgets/app_background.dart';
import 'package:application/app/widgets/app_button.dart';
import 'package:application/app/widgets/app_logo.dart';
import 'package:application/app/widgets/app_toast.dart';
import 'package:application/app/widgets/entrance_stagger.dart';
import 'package:application/app/widgets/refresh_view.dart';
import 'package:application/state/cloud_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    final controller = context.read<CloudController>();
    final success = await controller.loginCloud(
      identifier: _identifierController.text.trim(),
      password: _passwordController.text,
    );
    if (success && mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  /// Pull-to-refresh: if a session already exists, go straight to Home.
  Future<void> _refresh() async {
    final loggedIn = context.read<CloudController>().isConnected;
    if (loggedIn && mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<CloudController>();
    final errorText = controller.errorCode == null
        ? null
        : controller.errorCode == 'network_error'
            ? 'Server unreachable. Check your connection.'
            : controller.errorCode == 'invalid_credentials' || controller.errorCode == 'auth_error'
                ? 'Invalid username or password.'
                : 'Authentication failed. Please try again.';

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: RefreshView(
            onRefresh: _refresh,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: ClampingScrollPhysics(),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Form(
                    key: _formKey,
                    child: EntranceStagger(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: 24,
                      children: [
                        const SizedBox(height: 32),
                        const AppLogo(size: 110),
                        Column(
                          children: [
                            const Text(
                              'MentalMood',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 34,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'A quiet space for your daily check-ins',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 15,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _identifierController,
                          textInputAction: TextInputAction.next,
                          style: const TextStyle(color: AppColors.textPrimary),
                          decoration: const InputDecoration(
                            labelText: 'Username or Email',
                            prefixIcon: Icon(
                              Icons.person_outline_rounded,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Required'
                              : null,
                        ),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _handleLogin(),
                          style: const TextStyle(color: AppColors.textPrimary),
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(
                              Icons.lock_outline_rounded,
                              color: AppColors.textSecondary,
                            ),
                            suffixIcon: IconButton(
                              onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                size: 20,
                                color: AppColors.textSecondary,
                              ),
                              tooltip: _obscurePassword
                                  ? 'Show password'
                                  : 'Hide password',
                            ),
                          ),
                          validator: (v) =>
                              (v == null || v.isEmpty) ? 'Required' : null,
                        ),
                        if (errorText != null)
                          Text(
                            errorText,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.danger,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        const SizedBox(height: 8),
                        AppButton(
                          label: 'Sign In',
                          onPressed: controller.isLoading ? null : _handleLogin,
                          isLoading: controller.isLoading,
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () =>
                              Navigator.pushNamed(context, '/register'),
                          child: const Text('New here? Create an account'),
                        ),
                        TextButton(
                          onPressed: () => _showForgotPassword(context),
                          child: const Text(
                            'Forgot password?',
                            style: TextStyle(color: AppColors.textFaint),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showForgotPassword(BuildContext context) async {
    final identifier = TextEditingController();
    final sent = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter your username or email: we will send you '
              'a link to reset your password.',
            ),
            const SizedBox(height: 12),
            TextField(
              controller: identifier,
              decoration: const InputDecoration(labelText: 'Username or email'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final cloud = context.read<CloudController>();
              await cloud.requestPasswordReset(identifier.text.trim());
              if (ctx.mounted) Navigator.pop(ctx, true);
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
    if (sent == true && mounted) {
      AppToast.show(
        context,
        'Instructions sent to your email.',
        type: AppToastType.success,
      );
    }
  }
}
