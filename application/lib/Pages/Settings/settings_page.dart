import 'dart:ui';
import 'package:application/Logic/login_controller.dart';
import 'package:application/Logic/mood_controller.dart';
import 'package:application/Utils/animations.dart';
import 'package:application/Utils/theme.dart';
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
  late DateTime _selectedDate;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<LoginController>().currentUser!;
    _nameController = TextEditingController(text: user.name);
    _surnameController = TextEditingController(text: user.surname);
    _selectedDate = user.birthDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    super.dispose();
  }

  Future<void> _handleUpdate() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isProcessing = true);
    final controller = context.read<LoginController>();
    await controller.updateProfile(
      name: _nameController.text.trim(), 
      surname: _surnameController.text.trim(), 
      birthDate: _selectedDate
    );
    if (mounted) {
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated.'), behavior: SnackBarBehavior.floating)
      );
    }
  }

  Future<void> _confirmAction({
    required String title,
    required String message,
    required Future<void> Function() onConfirm,
    bool isDestructive = false,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDestructive ? AppTheme.terracottaError : AppTheme.accent,
              foregroundColor: Colors.white,
            ),
            child: const Text("Confirm"),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) await onConfirm();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<LoginController>().currentUser;
    if (user == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(title: const Text("Profile")),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                FadeInSlide(
                  child: _GlassCard(
                    padding: const EdgeInsets.all(32),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 35, 
                          backgroundColor: Colors.white.withValues(alpha: 0.1), 
                          child: Text(user.name[0].toUpperCase(), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white))
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("${user.name} ${user.surname}", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                              const Text("App Member", style: TextStyle(color: Colors.white38, fontSize: 13)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 48),
                _buildLabel("Personal Info"),
                const SizedBox(height: 12),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController, 
                        decoration: const InputDecoration(labelText: "Name"), 
                        style: const TextStyle(color: Colors.white),
                        validator: (v) => (v == null || v.isEmpty) ? "Required" : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _surnameController, 
                        decoration: const InputDecoration(labelText: "Surname"), 
                        style: const TextStyle(color: Colors.white),
                        validator: (v) => (v == null || v.isEmpty) ? "Required" : null,
                      ),
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: () async {
                          final p = await showDatePicker(context: context, initialDate: _selectedDate, firstDate: DateTime(1900), lastDate: DateTime.now());
                          if (p != null) setState(() => _selectedDate = p);
                        },
                        borderRadius: BorderRadius.circular(18),
                        mouseCursor: SystemMouseCursors.click,
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(18)),
                          child: Row(
                            children: [
                              const Icon(Icons.cake_rounded, color: Colors.white54, size: 20),
                              const SizedBox(width: 12),
                              Text(DateFormat('dd/MM/yyyy').format(_selectedDate), style: const TextStyle(color: Colors.white, fontSize: 16)),
                              const Spacer(),
                              const Text("Change", style: TextStyle(color: AppTheme.accent, fontWeight: FontWeight.bold, fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(onPressed: _handleUpdate, child: const Text("SAVE CHANGES")),
                    ],
                  ),
                ),
                const SizedBox(height: 56),
                _buildLabel("Journal Management"),
                const SizedBox(height: 12),
                _GlassCard(
                  child: Column(
                    children: [
                      _Tile(
                        title: "Generate Mock Data", 
                        icon: Icons.storage_rounded, 
                        color: Colors.amber, 
                        onTap: () => _confirmAction(
                          title: "Seed Data?",
                          message: "Add random entries for testing.",
                          onConfirm: () async {
                            setState(() => _isProcessing = true);
                            await context.read<MoodController>().seedMockData(user.id);
                            setState(() => _isProcessing = false);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Mock data generated."), behavior: SnackBarBehavior.floating)
                              );
                            }
                          }
                        )
                      ),
                      const Divider(height: 1, indent: 64, color: Colors.white10),
                      _Tile(
                        title: "Cleanup History", 
                        icon: Icons.history_rounded, 
                        color: AppTheme.sagePrimary, 
                        onTap: () async {
                          final date = await showDatePicker(context: context, initialDate: DateTime.now().subtract(const Duration(days: 30)), firstDate: DateTime(1900), lastDate: DateTime.now());
                          if (date != null) {
                            await _confirmAction(
                              title: "Delete Entries?",
                              message: "Delete logs before ${DateFormat('dd/MM/yyyy').format(date)}?",
                              isDestructive: true,
                              onConfirm: () async {
                                await context.read<MoodController>().clearHistoryBefore(user.id, date);
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Selected history cleared."), behavior: SnackBarBehavior.floating)
                                  );
                                }
                              }
                            );
                          }
                        }
                      ),
                      const Divider(height: 1, indent: 64, color: Colors.white10),
                      _Tile(
                        title: "Wipe All Data",
                        icon: Icons.delete_sweep_rounded,
                        color: AppTheme.terracottaError,
                        onTap: () => _confirmAction(
                          title: "Clear Journal?",
                          message: "Every entry will be deleted permanently.",
                          isDestructive: true,
                          onConfirm: () async {
                            await context.read<MoodController>().clearHistory(user.id);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Journal wiped clean."), behavior: SnackBarBehavior.floating)
                              );
                            }
                          }
                        )
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),
                _buildLabel("Account", isDanger: true),
                const SizedBox(height: 12),
                _GlassCard(
                  child: Column(
                    children: [
                      _Tile(
                        title: "Logout", 
                        icon: Icons.logout_rounded, 
                        color: Colors.white54, 
                        onTap: () => _confirmAction(
                          title: "Sign Out?",
                          message: "Log out from your account?",
                          onConfirm: () async {
                            await context.read<LoginController>().logout();
                            if (mounted) Navigator.pushReplacementNamed(context, '/login');
                          }
                        )
                      ),
                      const Divider(height: 1, indent: 64, color: Colors.white10),
                      _Tile(
                        title: "Delete Account", 
                        icon: Icons.person_remove_rounded, 
                        color: AppTheme.terracottaError, 
                        onTap: () => _confirmAction(
                          title: "Delete Forever?",
                          message: "This will erase your account and all data. Irreversible.",
                          isDestructive: true,
                          onConfirm: () async {
                            setState(() => _isProcessing = true);
                            await context.read<LoginController>().deleteAccount();
                            if (mounted) Navigator.pushReplacementNamed(context, '/login');
                          }
                        )
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 160),
              ],
            ),
          ),
        ),
        if (_isProcessing)
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.6),
              child: const Center(child: CircularProgressIndicator()),
            ),
          ),
      ],
    );
  }

  Widget _buildLabel(String t, {bool isDanger = false}) => Align(
    alignment: Alignment.centerLeft, 
    child: Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(t.toUpperCase(), style: TextStyle(fontWeight: FontWeight.w900, color: isDanger ? AppTheme.terracottaError : Colors.white24, letterSpacing: 1.5, fontSize: 11))
    )
  );
}

class _Tile extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _Tile({required this.title, required this.icon, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle), child: Icon(icon, color: color, size: 20)),
      title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
      trailing: const Icon(Icons.chevron_right_rounded, color: Colors.white10, size: 18),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  const _GlassCard({required this.child, this.padding});
  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        shape: ContinuousRectangleBorder(
          borderRadius: BorderRadius.circular(56),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.08), width: 1.2),
        ),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
          ),
          child: child,
        ),
      ),
    );
  }
}
