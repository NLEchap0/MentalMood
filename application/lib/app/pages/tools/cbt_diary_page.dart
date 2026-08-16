import 'package:application/app/theme/app_colors.dart';
import 'package:application/app/widgets/app_button.dart';
import 'package:application/services/ai_controller.dart';
import 'package:application/services/auth_api_client.dart';
import 'package:application/state/cloud_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Diario CBT a schermo intero: situazione + pensiero, l'AI ristruttura.
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
      appBar: AppBar(title: const Text('Diario CBT')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Descrivi il pensiero negativo e la situazione: l'AI ti aiuta "
              'a identificare le distorsioni e a ristrutturarlo.',
              style: TextStyle(color: AppColors.textFaint, fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _situationController,
              decoration: const InputDecoration(labelText: 'Situazione'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _thoughtController,
              decoration: const InputDecoration(labelText: 'Pensiero'),
            ),
            const SizedBox(height: 20),
            AppButton(
              label: 'Ristruttura',
              isLoading: controller.state == AiState.loading,
              onPressed: _submit,
            ),
            if (controller.lastReply != null) ...[
              const SizedBox(height: 24),
              const Text(
                'Ristrutturazione',
                style: TextStyle(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  controller.lastReply!,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
