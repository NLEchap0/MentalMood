import 'package:application/app/theme/app_colors.dart';
import 'package:application/app/widgets/app_button.dart';
import 'package:application/services/auth_api_client.dart';
import 'package:application/state/auth_controller.dart';
import 'package:application/state/cloud_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

/// Pagina piani: scegli Standard o Pro e paga con Stripe (checkout in-app).
/// Mostra sempre il piano attuale dell'utente.
class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key});

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  String? _selectedPlan;
  bool _processing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<CloudController>().refreshSubscription();
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final cloud = context.watch<CloudController>();
    final info = cloud.subscription;
    final currentPlan = info?.plan ?? cloud.session?.plan ?? 'free';
    final session = cloud.session;

    return Scaffold(
      appBar: AppBar(title: const Text('Piani')),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          const Text(
            'Scegli il piano che fa per te',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            info == null
                ? 'Carica il tuo piano…'
                : 'Piano attuale: ${_planLabel(currentPlan)}'
                    '${info.status == 'trialing' ? ' (prova gratuita)' : ''}',
            style: const TextStyle(color: AppColors.textFaint, fontSize: 13),
          ),
          const SizedBox(height: 20),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                _error!,
                style: const TextStyle(color: AppColors.danger, fontSize: 13),
              ),
            ),
          _planCard(
            plan: 'free',
            title: 'Free',
            price: '€0',
            period: 'per sempre',
            features: const [
              'Check-in giornalieri illimitati',
              'Statistiche e streak',
              'Questionari PHQ-9 e GAD-7',
              'Export dati (GDPR)',
            ],
            isCurrent: currentPlan == 'free',
            onSelect: currentPlan == 'free' ? null : null,
          ),
          const SizedBox(height: 14),
          _planCard(
            plan: 'standard',
            title: 'Standard',
            price: '€3,99',
            period: 'al mese',
            features: const [
              'Tutto di Free',
              'Backup cloud end-to-end criptato',
              'Sync tra dispositivi',
              'Widget home screen',
            ],
            isCurrent: currentPlan == 'standard',
            isSelected: _selectedPlan == 'standard',
            onSelect: () => setState(() => _selectedPlan = 'standard'),
          ),
          const SizedBox(height: 14),
          _planCard(
            plan: 'pro',
            title: 'Pro',
            price: '€9,99',
            period: 'al mese',
            features: const [
              'Tutto di Standard',
              'Chat AI illimitata',
              'Diario CBT guidato',
              'Insight e consigli personalizzati',
              'Report condivisibile',
            ],
            isCurrent: currentPlan == 'pro',
            isSelected: _selectedPlan == 'pro',
            onSelect: () => setState(() => _selectedPlan = 'pro'),
          ),
          const SizedBox(height: 24),
          AppButton(
            label: _selectedPlan == null
                ? (currentPlan == 'free'
                    ? 'Seleziona un piano'
                    : 'Il tuo piano è attivo')
                : 'Paga con Stripe · $_selectedPlan',
            onPressed:
                (_selectedPlan == null || _processing || session == null)
                    ? null
                    : () => _checkout(session),
            isLoading: _processing,
          ),
          const SizedBox(height: 12),
          const Text(
            'Prova gratuita di 14 giorni su Standard e Pro. '
            'Puoi annullare quando vuoi.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textFaint, fontSize: 11.5),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  String _planLabel(String plan) => switch (plan) {
        'pro' => 'Pro',
        'standard' => 'Standard',
        _ => 'Free',
      };

  Widget _planCard({
    required String plan,
    required String title,
    required String price,
    required String period,
    required List<String> features,
    required bool isCurrent,
    bool isSelected = false,
    VoidCallback? onSelect,
  }) {
    final borderColor = isCurrent
        ? AppColors.success
        : isSelected
            ? AppColors.accent
            : Colors.white.withValues(alpha: 0.06);

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onSelect,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor, width: isCurrent ? 1.6 : 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  if (isCurrent)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Attivo',
                        style: TextStyle(
                          color: AppColors.success,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    price,
                    style: const TextStyle(
                      color: AppColors.accent,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      period,
                      style: const TextStyle(
                        color: AppColors.textFaint,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              for (final f in features)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle_outline_rounded,
                        color: AppColors.success,
                        size: 17,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          f,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _checkout(AuthSession session) async {
    setState(() {
      _processing = true;
      _error = null;
    });
    final cloud = context.read<CloudController>();
    final auth = context.read<AuthController>();
    try {
      final url = await cloud.api.checkout(
        accessToken: session.accessToken,
        plan: _selectedPlan!,
        email: null,
      );
      final launched = await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        setState(() {
          _error = 'Impossibile aprire il pagamento. Riprova.';
        });
      }
      // Dopo il ritorno dal checkout, aggiorna lo stato del piano.
      await Future<void>.delayed(const Duration(seconds: 2));
      await cloud.refreshSubscription();
      await auth.refreshProfile();
    } on CloudApiFailure catch (e) {
      setState(() {
        _error = switch (e.code) {
          'plan_invalid' => 'Piano non valido.',
          'network_error' => 'Server non raggiungibile.',
          _ => 'Errore: ${e.code}',
        };
      });
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }
}
