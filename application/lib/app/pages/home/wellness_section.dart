import 'package:application/app/pages/settings/subscription_gate.dart';
import 'package:application/app/pages/tools/chat_ai_page.dart';
import 'package:application/app/pages/tools/cbt_diary_page.dart';
import 'package:application/app/pages/tools/insights_page.dart';
import 'package:application/app/theme/app_colors.dart';
import 'package:application/app/widgets/section_header.dart';
import 'package:application/services/questionnaire_service.dart';
import 'package:application/state/auth_controller.dart';
import 'package:application/state/cloud_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Sezione "Benessere" integrata nella Home: chat AI, questionari,
/// diario CBT e insight — con gating per piano (free → pagina piani).
class WellnessSection extends StatelessWidget {
  const WellnessSection({super.key});

  @override
  Widget build(BuildContext context) {
    final cloud = context.watch<CloudController>();
    final session = cloud.session;
    final isPro = cloud.subscription?.plan == 'pro' ||
        cloud.session?.plan == 'pro';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: SectionHeader(title: 'Wellness'),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _featureTile(
                context,
                icon: Icons.auto_awesome_rounded,
                color: AppColors.accent,
                title: 'Chat AI',
                subtitle: 'Assistente 24/7',
                locked: !isPro,
                onTap: () => _openGated(
                  context,
                  requiresPro: true,
                  page: const ChatAiPage(),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _featureTile(
                context,
                icon: Icons.assignment_outlined,
                color: AppColors.success,
                title: 'Questionari',
                subtitle: 'PHQ-9 · GAD-7',
                locked: false,
                onTap: () => _openQuestionnairePicker(context),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _featureTile(
                context,
                icon: Icons.psychology_outlined,
                color: AppColors.gold,
                title: 'Diario CBT',
                subtitle: 'Ristruttura i pensieri',
                locked: !isPro,
                onTap: () => _openGated(
                  context,
                  requiresPro: true,
                  page: const CbtDiaryPage(),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _featureTile(
                context,
                icon: Icons.insights_outlined,
                color: AppColors.textSecondary,
                title: 'Insight',
                subtitle: 'Analisi dei pattern',
                locked: !isPro,
                onTap: () => _openGated(
                  context,
                  requiresPro: true,
                  page: const InsightsPage(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        if (session == null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'Collega il tuo account cloud per usare le funzioni AI.',
              style: TextStyle(
                color: AppColors.textFaint.withValues(alpha: 0.9),
                fontSize: 12,
              ),
            ),
          )
        else if (!isPro)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: TextButton(
              onPressed: () => openSubscriptionPage(context),
              child: const Text(
                'Passa a Pro per sbloccare Chat AI, CBT e Insight →',
                style: TextStyle(color: AppColors.accent, fontSize: 12.5),
              ),
            ),
          ),
      ],
    );
  }

  void _openGated(
    BuildContext context, {
    required bool requiresPro,
    required Widget page,
  }) {
    final cloud = context.read<CloudController>();
    final isPro = cloud.subscription?.plan == 'pro' ||
        cloud.session?.plan == 'pro';
    if (cloud.session == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Collega il tuo account cloud dalla pagina Profilo.'),
        ),
      );
      return;
    }
    if (requiresPro && !isPro) {
      openSubscriptionPage(context);
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  void _openQuestionnairePicker(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const QuestionnairesPage()),
    );
  }

  Widget _featureTile(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required bool locked,
    VoidCallback? onTap,
  }) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.14),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: color, size: 19),
                  ),
                  const Spacer(),
                  if (locked)
                    const Icon(
                      Icons.lock_outline_rounded,
                      color: AppColors.textFaint,
                      size: 16,
                    )
                  else
                    Icon(
                      Icons.chevron_right_rounded,
                      color: color.withValues(alpha: 0.7),
                      size: 18,
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppColors.textFaint,
                  fontSize: 11.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Pagina questionari PHQ-9 / GAD-7 (schermata dedicata).
class QuestionnairesPage extends StatefulWidget {
  const QuestionnairesPage({super.key});

  @override
  State<QuestionnairesPage> createState() => _QuestionnairesPageState();
}

class _QuestionnairesPageState extends State<QuestionnairesPage> {
  static const _phq9 = [
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

  static const _gad7 = [
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
    return Scaffold(
      appBar: AppBar(title: const Text('Questionari')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _questionnaireCard(
            context,
            icon: Icons.healing_outlined,
            title: 'PHQ-9 — Depressione',
            subtitle: '9 domande sulla scorsa settimana',
            questions: _phq9,
            type: 'phq9',
          ),
          const SizedBox(height: 14),
          _questionnaireCard(
            context,
            icon: Icons.psychology_outlined,
            title: 'GAD-7 — Ansia',
            subtitle: '7 domande sulla scorsa settimana',
            questions: _gad7,
            type: 'gad7',
          ),
          const SizedBox(height: 20),
          const Text(
            'Questi test sono strumenti informativi e non sostituiscono '
            'un professionista sanitario.',
            style: TextStyle(color: AppColors.textFaint, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _questionnaireCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required List<String> questions,
    required String type,
  }) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: () => _run(context, type, questions),
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.accent, size: 28),
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
                      ),
                    ),
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
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textFaint,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _run(
    BuildContext context,
    String type,
    List<String> questions,
  ) async {
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
              const SizedBox(height: 12),
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

    final result = await QuestionnaireService().save(
      userId: context.read<AuthController>().currentUser?.id ?? 0,
      type: type,
      answers: answers,
    );
    if (!mounted) return;
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
}
