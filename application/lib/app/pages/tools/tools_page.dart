import 'package:application/app/pages/tools/chat_ai_page.dart';
import 'package:application/app/pages/tools/cbt_diary_page.dart';
import 'package:application/app/pages/tools/insights_page.dart';
import 'package:application/app/theme/app_colors.dart';
import 'package:application/app/widgets/glass_card.dart';
import 'package:application/data/repositories/emotion_repository.dart';
import 'package:application/services/checkin_scheduler.dart';
import 'package:application/services/monthly_report_generator.dart';
import 'package:application/services/questionnaire_service.dart';
import 'package:application/state/auth_controller.dart';
import 'package:application/state/cloud_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Tab "Tools": tutte le feature attive dell'app in un posto dedicato,
/// come nelle app di benessere. Chat AI a schermo intero, il resto come card.
class ToolsPage extends StatelessWidget {
  const ToolsPage({super.key});

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

    return Scaffold(
      appBar: AppBar(title: const Text('Tools')),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          _heroCard(context, connected),
          const SizedBox(height: 20),
          const Text(
            'Esplora',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          _featureCard(
            context,
            icon: Icons.chat_bubble_outline_rounded,
            color: AppColors.success,
            title: 'Chat AI',
            subtitle: 'Parla con il tuo assistente di benessere',
            onTap: connected
                ? () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ChatAiPage()),
                  )
                : null,
          ),
          const SizedBox(height: 12),
          _featureCard(
            context,
            icon: Icons.assignment_outlined,
            color: AppColors.accent,
            title: 'Questionari',
            subtitle: 'PHQ-9 depressione · GAD-7 ansia',
            onTap: () => _showQuestionnairePicker(context),
          ),
          const SizedBox(height: 12),
          _featureCard(
            context,
            icon: Icons.psychology_outlined,
            color: AppColors.textSecondary,
            title: 'Diario CBT',
            subtitle: "Ristruttura i pensieri con l'AI",
            onTap: connected
                ? () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CbtDiaryPage()),
                  )
                : null,
          ),
          const SizedBox(height: 12),
          _featureCard(
            context,
            icon: Icons.insights_outlined,
            color: AppColors.accent,
            title: 'Insight',
            subtitle: 'I tuoi pattern di umore',
            onTap: connected
                ? () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const InsightsPage()),
                  )
                : null,
          ),
          const SizedBox(height: 12),
          _featureCard(
            context,
            icon: Icons.description_outlined,
            color: AppColors.gold,
            title: 'Report mensile',
            subtitle: 'PDF con le statistiche del mese',
            onTap: () => _generateReport(context),
          ),
          const SizedBox(height: 12),
          _featureCard(
            context,
            icon: Icons.notifications_outlined,
            color: AppColors.danger,
            title: 'Check-in notifiche',
            subtitle: 'Promemoria giornaliero del tuo umore',
            onTap: () => _openCheckinSettings(context),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _heroCard(BuildContext context, bool connected) {
    return GlassCard(
      size: GlassCardSize.sm,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.14),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: AppColors.accent,
                size: 26,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Il tuo spazio di benessere',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    connected
                        ? 'Tutte le funzioni sono disponibili.'
                        : "Connecta il tuo account cloud per usare l'AI.",
                    style: const TextStyle(
                      color: AppColors.textFaint,
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _featureCard(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.textFaint,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                onTap == null
                    ? Icons.lock_outline_rounded
                    : Icons.chevron_right_rounded,
                color: onTap == null
                    ? AppColors.textFaint
                    : AppColors.textSecondary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

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
      if (answer == null) return;
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
