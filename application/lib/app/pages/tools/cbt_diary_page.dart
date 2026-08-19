import 'package:application/app/theme/app_colors.dart';
import 'package:application/app/widgets/app_button.dart';
import 'package:application/services/ai_controller.dart';
import 'package:application/services/auth_api_client.dart';
import 'package:application/state/cloud_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Full-screen CBT diary: situation + thought, AI restructures it.
class CbtDiaryPage extends StatefulWidget {
  const CbtDiaryPage({super.key});

  @override
  State<CbtDiaryPage> createState() => _CbtDiaryPageState();
}

class _CbtDiaryPageState extends State<CbtDiaryPage> {
  final _situationController = TextEditingController();
  final _thoughtController = TextEditingController();

  @override
  void dispose() {
    _situationController.dispose();
    _thoughtController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final controller = context.read<AiController>();
    final cloud = context.read<CloudController>();
    final session = cloud.session;
    if (session == null) return;
    final t = _thoughtController.text.trim();
    final s = _situationController.text.trim();
    if (t.isEmpty || s.isEmpty) return;

    setState(() {});
    await controller.sendCbt(
      baseUrl: apiBaseUrl(),
      accessToken: session.accessToken,
      thought: t,
      situation: s,
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AiController>();

    return Scaffold(
      appBar: AppBar(title: const Text('CBT Diary')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  "Describe the negative thought and the situation: AI helps you "
                  'identify distortions and restructure it.',
                  style: TextStyle(color: AppColors.textFaint, fontSize: 13, height: 1.4),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _situationController,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    labelText: 'Situation',
                    hintText: 'What happened?',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _thoughtController,
                  maxLines: 2,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    labelText: 'Negative Thought',
                    hintText: 'What are you telling yourself?',
                  ),
                ),
                const SizedBox(height: 24),
                AppButton(
                  label: 'Restructure Thought',
                  icon: Icons.auto_awesome_rounded,
                  isLoading: controller.state == AiState.loading,
                  onPressed: _submit,
                ),
                if (controller.lastReply != null) ...[
                  const SizedBox(height: 32),
                  const Text(
                    'RESTRUCTURING',
                    style: TextStyle(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.accent.withValues(alpha: 0.15)),
                    ),
                    child: Text(
                      controller.lastReply!,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        height: 1.5,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
