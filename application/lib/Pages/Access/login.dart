import 'package:application/Logic/login_controller.dart';
import 'package:application/Pages/Access/register.dart';
import 'package:application/Utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    final controller = context.read<LoginController>();
    final success = await controller.login(_usernameController.text, _passwordController.text);
    if (success && mounted) Navigator.of(context).pushReplacementNamed('/home');
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<LoginController>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(40.0),
              child: Form(
                key: _formKey,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), shape: BoxShape.circle),
                        child: const Icon(Icons.spa_rounded, size: 64, color: AppTheme.accent),
                      ),
                      const SizedBox(height: 32),
                      const Text("MentalMood", style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -1.5)),
                      const SizedBox(height: 8),
                      const Text("Your sanctuary for mindfulness.", style: TextStyle(color: Colors.white54, fontSize: 16)),
                      const SizedBox(height: 60),
                      TextFormField(
                        controller: _usernameController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(labelText: "Username", prefixIcon: Icon(Icons.person_outline_rounded, color: Colors.white54)),
                        validator: (v) => (v == null || v.isEmpty) ? "Enter username" : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(labelText: "Password", prefixIcon: Icon(Icons.lock_outline_rounded, color: Colors.white54)),
                        validator: (v) => (v == null || v.isEmpty) ? "Enter password" : null,
                      ),
                      if (controller.errorMessage != null) ...[
                        const SizedBox(height: 16),
                        Text(controller.errorMessage!, style: const TextStyle(color: AppTheme.terracottaError, fontWeight: FontWeight.bold)),
                      ],
                      const SizedBox(height: 48),
                      ElevatedButton(
                        onPressed: controller.isLoading ? null : _handleLogin,
                        child: controller.isLoading 
                          ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2)) 
                          : const Text("SIGN IN"),
                      ),
                      const SizedBox(height: 24),
                      TextButton(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const Register())),
                        child: const Text("New here? Create account", style: TextStyle(color: AppTheme.accent, fontWeight: FontWeight.bold)),
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
