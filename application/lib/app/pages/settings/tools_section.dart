import 'package:application/app/theme/app_colors.dart';
import 'package:application/app/widgets/app_button.dart';
import 'package:application/app/widgets/glass_card.dart';
import 'package:application/data/repositories/emotion_repository.dart';
import 'package:application/services/ai_controller.dart';
import 'package:application/services/auth_api_client.dart';
import 'package:application/services/checkin_scheduler.dart';
import 'package:application/services/monthly_report_generator.dart';
import 'package:application/services/questionnaire_service.dart';
import 'package:application/state/auth_controller.dart';
import 'package:application/state/cloud_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Sezione "Tools & AI": questionari PHQ-9/GAD-7, report mensile PDF,
/// chat AI, diario CBT guidato, insight settimanali e check-in notifiche.
class ToolsSection extends StatelessWidget {
  const ToolsSection({super.key});

  static const _phq9Questions = [
    'Poco interesse o piacere nel fare le cose',
    'Sentirsi giù, depresso o senza speranza',
    'Difficoltà ad addormentarsi o dormire troppo',
    'Sentirsi stanco o con poca energia',
    'Scarso appetito o mangiare troppo',
    'Sentirsi male con sé stesso o sentirsi un fallimento',
    'Difficoltà a concentrarsi',
    'Muoversi o parlare più lentamente del solito',
    'Pensieri di farsi del male',
  ];

  static const _gad7Questions = [
    'Sentirsi nervoso, ansioso o con i nervi a fior di pelle',
    'Non riuscire a smettere di preoccuparsi',
    'Preoccuparsi troppo per cose diverse',
    'Difficoltà a rilassarsi',
    'Essere così irrequieto da non riuscire a stare fermo',
    'Infastidirsi o irritarsi facilmente',
    'Avere paura che stia per succedere qualcosa di terribile',
  ];

  @override
  Widget build(BuildContext context) {
    final cloud = context.watch<CloudController>();
    final connected = cloud.isConnected;

    return GlassCard(
      size: GlassCardSize.sm,
      child: Column(
        children: [
          _tile(
            context,
            title: 'Questionari',
            subtitle: 'PHQ-9 depressione · GAD-7 ansia',
            icon: Icons.assignment_outlined,
            color: AppColors.accent,
            onTap: () => _showQuestionnairePicker(context),
          ),
          const Divider(indent: 64),
          _tile(
            context,
            title: 'Report mensile',
            subtitle: 'PDF con statistiche del mese, da condividere',
            icon: Icons.description_outlined,
            color: AppColors.gold,
            onTap: () => _generateReport(context),
          ),
          const Divider(indent: 64),
          _tile(
            context,
            title: 'Chat AI',
            subtitle: connected
                ? 'Parla con il tuo assistente di benessere'
                : 'Connecta il cloud per usare l\'AI',
            icon: Icons.chat_outlined,
            color: AppColors.success,
            onTap: connected ? () => _openChat(context) : null,
          ),
          const Divider(indent: 64),
          _tile(
            context,
            title: 'Diario CBT',
            subtitle: 'Ristruttura i pensieri con l\'AI',
            icon: Icons.psychology_outlined,
            color: AppColors.textSecondary,
            onTap: connected ? () => _openCbt(context) : null,
          ),
          const Divider(indent: 64),
          _tile(
            context,
            title: 'Insight settimanali',
            subtitle: connected
                ? 'Analisi dei tuoi pattern di umore'
                : 'Connecta il cloud per vedere gli insight',
            icon: Icons.insights_outlined,
            color: AppColors.accent,
            onTap: connected ? () => _openInsights(context) : null,
          ),
          const Divider(indent: 64),
          _tile(
            context,
            title: 'Check-in notifiche',
            subtitle: 'Promemoria giornaliero del tuo umore',
            icon: Icons.notifications_outlined,
            color: AppColors.danger,
            onTap: () => _openCheckinSettings(context),
          ),
        ],
      ),
    );
  }

  Widget _tile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
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
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: AppColors.textFaint, fontSize: 11.5),
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

  // --- QUESTIONARI ---

  void _showQuestionnairePicker(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.healing_outlined, color: AppColors.accent),
              title: const Text(
                'PHQ-9 — Depressione',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: const Text('9 domande sulla scorsa settimana'),
              onTap: () {
                Navigator.pop(ctx);
                _runQuestionnaire(context, 'phq9', _phq9Questions);
              },
            ),
            ListTile(
              leading: const Icon(Icons.psychology_outlined, color: AppColors.accent),
              title: const Text(
                'GAD-7 — Ansia',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: const Text('7 domande sulla scorsa settimana'),
              onTap: () {
                Navigator.pop(ctx);
                _runQuestionnaire(context, 'gad7', _gad7Questions);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _runQuestionnaire(
    BuildContext context,
    String type,
    List<String> questions,
  ) async {
    final userId = context.read<AuthController>().currentUser?.id ?? 0;
    final answers = <int>[];
    for (var i = 0; i < questions.length; i++) {
      final answer = await showDialog<int>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Domanda ${i + 1}/${questions.length}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(questions[i]),
              const SizedBox(height: 16),
              for (var v = 0; v <= 3; v++)
                ListTile(
                  title: Text(
                    switch (v) {
                      0 => 'Per niente',
                      1 => 'Diversi giorni',
                      2 => 'Più della metà dei giorni',
                      _ => 'Quasi ogni giorno',
                    },
                  ),
                  leading: Icon(
                    v == 0
                        ? Icons.sentiment_satisfied_outlined
                        : v == 3
                            ? Icons.sentiment_very_dissatisfied_outlined
                            : Icons.sentiment_neutral_outlined,
                    color: AppColors.textSecondary,
                  ),
                  onTap: () => Navigator.pop(ctx, v),
                ),
            ],
          ),
        ),
      );
      if (answer == null) return; // annullato
      answers.add(answer);
    }

    final service = QuestionnaireService();
    final result = await service.save(
      userId: userId,
      type: type,
      answers: answers,
    );
    if (!context.mounted) return;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Risultato'),
        content: Text(
          'Punteggio: ${result.totalScore}\n'
          'Livello: ${result.severity}\n\n'
          'Questo strumento è informativo e non sostituisce un '
          'professionista sanitario.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // --- REPORT PDF ---

  Future<void> _generateReport(BuildContext context) async {
    final repo = context.read<EmotionRepository>();
    final userId = context.read<AuthController>().currentUser?.id ?? 0;
    final now = DateTime.now();
    final generator = MonthlyReportGenerator(
      emotions: repo,
      fileWriter: TempDirFileWriter(),
      now: () => now,
    );
    final bytes = await generator.generate(
      userId: userId,
      year: now.year,
      month: now.month,
    );
    final file = await generator.saveToTemp(
      bytes,
      'mentalmood-report-${now.year}-${now.month}.pdf',
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Report salvato in ${file.path}')));
  }

  // --- CHAT AI ---

  void _openChat(BuildContext context) {
    final controller = context.read<AiController>();
    final cloud = context.read<CloudController>();
    final session = cloud.session;
    if (session == null) return;
    final messageController = TextEditingController();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Chat AI',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              if (controller.lastReply != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    controller.lastReply!,
                    style: const TextStyle(color: AppColors.textPrimary),
                  ),
                ),
              const SizedBox(height: 12),
              TextField(
                controller: messageController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Il tuo messaggio'),
              ),
              const SizedBox(height: 16),
              AppButton(
                label: 'Invia',
                isLoading: controller.state == AiState.loading,
                onPressed: () async {
                  final text = messageController.text.trim();
                  if (text.isEmpty) return;
                  var ok = await controller.sendChat(
                    baseUrl: apiBaseUrl(),
                    accessToken: session.accessToken,
                    message: text,
                  );
                  if (!ok && controller.state == AiState.consentRequired) {
                    final granted = await controller.enableConsent(
                      baseUrl: apiBaseUrl(),
                      accessToken: session.accessToken,
                    );
                    if (granted) {
                      ok = await controller.sendChat(
                        baseUrl: apiBaseUrl(),
                        accessToken: session.accessToken,
                        message: text,
                      );
                    }
                  }
                  setSheetState(() {});
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- DIARIO CBT ---

  void _openCbt(BuildContext context) {
    final controller = context.read<AiController>();
    final cloud = context.read<CloudController>();
    final session = cloud.session;
    if (session == null) return;
    final thought = TextEditingController();
    final situation = TextEditingController();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Diario CBT',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Descrivi il pensiero negativo e la situazione: l\'AI ti aiuta '
                'a identificare le distorsioni e a ristrutturarlo.',
                style: TextStyle(color: AppColors.textFaint, fontSize: 12),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: situation,
                decoration: const InputDecoration(labelText: 'Situazione'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: thought,
                decoration: const InputDecoration(labelText: 'Pensiero'),
              ),
              const SizedBox(height: 16),
              if (controller.lastReply != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    controller.lastReply!,
                    style: const TextStyle(color: AppColors.textPrimary),
                  ),
                ),
              const SizedBox(height: 12),
              AppButton(
                label: 'Ristruttura',
                isLoading: controller.state == AiState.loading,
                onPressed: () async {
                  final t = thought.text.trim();
                  final s = situation.text.trim();
                  if (t.isEmpty || s.isEmpty) return;
                  await controller.sendCbt(
                    baseUrl: apiBaseUrl(),
                    accessToken: session.accessToken,
                    thought: t,
                    situation: s,
                  );
                  setSheetState(() {});
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- INSIGHT ---

  Future<void> _openInsights(BuildContext context) async {
    final controller = context.read<AiController>();
    final cloud = context.read<CloudController>();
    final session = cloud.session;
    if (session == null) return;
    await controller.loadInsights(
      baseUrl: apiBaseUrl(),
      accessToken: session.accessToken,
    );
    if (!context.mounted) return;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      builder: (ctx) => SafeArea(
        child: controller.insights.isEmpty
            ? const Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Nessun insight ancora disponibile. I insight vengono '
                  'generati periodicamente dai tuoi dati.',
                  style: TextStyle(color: AppColors.textFaint),
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                itemCount: controller.insights.length,
                itemBuilder: (_, i) {
                  final insight = controller.insights[i];
                  return ListTile(
                    leading: const Icon(Icons.insights, color: AppColors.accent),
                    title: Text(
                      insight.kind == 'weekly' ? 'Settimanale' : 'Mensile',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(insight.content),
                  );
                },
              ),
      ),
    );
  }

  // --- CHECK-IN ---

  void _openCheckinSettings(BuildContext context) {
    final scheduler = context.read<CheckinScheduler>();
    final userId = context.read<AuthController>().currentUser?.id ?? 0;
    final time = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Check-in giornaliero'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Ricevi un promemoria ogni giorno per registrare il tuo umore.',
            ),
            const SizedBox(height: 12),
            TextField(
              controller: time,
              decoration: const InputDecoration(
                labelText: 'Ora (HH:MM, es. 20:00)',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await scheduler.disable(userId);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Disattiva'),
          ),
          ElevatedButton(
            onPressed: () async {
              final parts = time.text.split(':');
              if (parts.length != 2) return;
              final hour = int.tryParse(parts[0]);
              final minute = int.tryParse(parts[1]);
              if (hour == null || minute == null || hour < 0 || hour > 23 || minute < 0 || minute > 59) {
                return;
              }
              final enabled = await scheduler.enable(
                time: TimeOfDay(hour: hour, minute: minute),
                userId: userId,
              );
              if (ctx.mounted) Navigator.pop(ctx);
              if (!enabled && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Permesso notifiche negato')),
                );
              }
            },
            child: const Text('Attiva'),
          ),
        ],
      ),
    );
  }
}
