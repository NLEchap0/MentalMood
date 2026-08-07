import 'package:application/Logic/register_controller.dart';
import 'package:application/Utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _passwordController = TextEditingController();
  DateTime _selectedDate = DateTime.now().subtract(const Duration(days: 365 * 20));

  void _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    final controller = context.read<RegisterController>();
    final success = await controller.register(
      username: _usernameController.text,
      name: _nameController.text,
      surname: _surnameController.text,
      password: _passwordController.text,
      birthDate: _selectedDate,
    );
    if (success && mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<RegisterController>();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(title: const Text("New Journey")),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Create Account", style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -1)),
                  const SizedBox(height: 8),
                  const Text("Start your mindful journaling.", style: TextStyle(color: Colors.white54, fontSize: 16)),
                  const SizedBox(height: 48),
                  TextFormField(
                    controller: _usernameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(labelText: "Username", prefixIcon: Icon(Icons.person_outline_rounded, color: Colors.white54)),
                    validator: (v) => (v == null || v.isEmpty) ? "Required" : null,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _nameController,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(labelText: "Name"),
                          validator: (v) => (v == null || v.isEmpty) ? "Required" : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _surnameController,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(labelText: "Surname"),
                          validator: (v) => (v == null || v.isEmpty) ? "Required" : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context, initialDate: _selectedDate, firstDate: DateTime(1900), lastDate: DateTime.now(),
                      );
                      if (picked != null) setState(() => _selectedDate = picked);
                    },
                    borderRadius: BorderRadius.circular(20),
                    mouseCursor: SystemMouseCursors.click,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(20)),
                      child: Row(
                        children: [
                          const Icon(Icons.cake_rounded, color: Colors.white54, size: 20),
                          const SizedBox(width: 12),
                          Text(DateFormat('dd/MM/yyyy').format(_selectedDate), style: const TextStyle(fontSize: 16, color: Colors.white)),
                          const Spacer(),
                          const Text("Birth Date", style: TextStyle(color: AppTheme.accent, fontWeight: FontWeight.bold, fontSize: 11)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(labelText: "Password", prefixIcon: Icon(Icons.lock_outline_rounded, color: Colors.white54)),
                    validator: (v) => (v == null || v.length < 4) ? "Too short" : null,
                  ),
                  if (controller.errorMessage != null) ...[
                    const SizedBox(height: 24),
                    Text(controller.errorMessage!, style: const TextStyle(color: AppTheme.terracottaError, fontWeight: FontWeight.bold)),
                  ],
                  const SizedBox(height: 48),
                  ElevatedButton(
                    onPressed: controller.isLoading ? null : _handleRegister,
                    child: controller.isLoading 
                      ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2)) 
                      : const Text("CREATE ACCOUNT"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
