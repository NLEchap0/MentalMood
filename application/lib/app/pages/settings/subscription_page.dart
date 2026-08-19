import 'package:application/app/theme/app_colors.dart';
import 'package:application/app/widgets/app_button.dart';
import 'package:application/services/auth_api_client.dart';
import 'package:application/state/auth_controller.dart';
import 'package:application/state/cloud_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

/// Plan page: choose Standard or Pro and pay with Stripe (in-app checkout).
/// Always shows the user's current plan.
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
    // Default: Pro selected (recommended plan).
    _selectedPlan = 'pro';
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
      appBar: AppBar(title: const Text('Plans')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            children: [
              const Text(
                'Choose the right plan for you',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                info == null
                    ? 'Loading your plan…'
                    : 'Current plan: ${_planLabel(currentPlan)}'
                        '${info.status == 'trialing' ? ' (free trial)' : ''}',
                style: const TextStyle(color: AppColors.textFaint, fontSize: 13),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.accent.withValues(alpha: 0.25),
                  ),
                ),
                child: const Text(
                  'Unlock the full power of your journal with Essential AI or '
                  'step up to Professional tools for a deeper mental health journey.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12.5,
                    height: 1.4,
                  ),
                ),
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
                period: 'forever',
                features: const [
                  'Unlimited daily check-ins',
                  'Statistics and streaks',
                  'PHQ-9 and GAD-7 questionnaires',
                ],
                isCurrent: currentPlan == 'free',
              ),
              const SizedBox(height: 14),
              _planCard(
                plan: 'standard',
                title: 'Standard',
                price: '€3.99',
                period: 'per month',
                badge: 'Essential',
                features: const [
                  'Everything in Free',
                  'E2EE Cloud Sync & Backup',
                  'AI Chat (Wellness Assistant)',
                  'Weekly Neural Insights',
                ],
                isCurrent: currentPlan == 'standard',
                isSelected: _selectedPlan == 'standard',
                onSelect: () => setState(() => _selectedPlan = 'standard'),
              ),
              const SizedBox(height: 14),
              _planCard(
                plan: 'pro',
                title: 'Pro',
                price: '€9.99',
                period: 'per month',
                badge: 'Professional',
                features: const [
                  'Everything in Standard',
                  'Advanced CBT Diary',
                  'Monthly Deep Analysis',
                  'Shareable Clinical PDF Reports',
                  'Proactive Mental Coaching',
                ],
                isCurrent: currentPlan == 'pro',
                isSelected: _selectedPlan == 'pro',
                onSelect: () => setState(() => _selectedPlan = 'pro'),
              ),
              const SizedBox(height: 24),
              AppButton(
                label: session == null
                    ? 'Connect your account to continue'
                    : (currentPlan != 'free' && _selectedPlan == currentPlan
                        ? 'Your plan is already active'
                        : 'Pay with Stripe · $_selectedPlan'),
                onPressed: _processing
                    ? null
                    : () {
                        if (session == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Connect your cloud account from the Profile page '
                                'before purchasing a plan.',
                              ),
                            ),
                          );
                          return;
                        }
                        _checkout(session);
                      },
                isLoading: _processing,
              ),
              const SizedBox(height: 12),
              const Text(
                '14-day free trial on Standard and Pro. '
                'Cancel anytime.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textFaint, fontSize: 11.5),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
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
    String? badge,
    VoidCallback? onSelect,
  }) {
    final highlighted = isSelected || badge != null;
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
            border: Border.all(color: borderColor, width: highlighted ? 1.8 : 1),
            boxShadow: highlighted
                ? [
                    BoxShadow(
                      color: isPro(plan) ? AppColors.gold.withValues(alpha: 0.12) : AppColors.accent.withValues(alpha: 0.12),
                      blurRadius: 18,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
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
                  if (badge != null)
                    Container(
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: (plan == 'pro' ? AppColors.gold : AppColors.accent).withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        badge,
                        style: TextStyle(
                          color: plan == 'pro' ? AppColors.gold : AppColors.accent,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
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
                        'Active',
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
                      color: AppColors.textPrimary,
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
                      Icon(
                        Icons.check_circle_outline_rounded,
                        color: isCurrent ? AppColors.success : (plan == 'pro' ? AppColors.gold : AppColors.accent).withValues(alpha: 0.6),
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

  bool isPro(String plan) => plan == 'pro';

  Future<void> _checkout(AuthSession session) async {
    setState(() {
      _processing = true;
      _error = null;
    });
    final cloud = context.read<CloudController>();
    final auth = context.read<AuthController>();
    try {
      final url = await cloud.checkoutCloud(_selectedPlan!);
      if (url == null) {
        if (mounted) {
          setState(() {
            _error = 'Unable to start checkout: ${cloud.errorCode ?? 'unknown error'}';
            _processing = false;
          });
        }
        return;
      }
      final launched = await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        setState(() {
          _error = 'Unable to open payment. Please try again.';
        });
      }
      // After returning from checkout, update the plan status.
      await Future<void>.delayed(const Duration(seconds: 2));
      await cloud.refreshSubscription();
      await auth.refreshProfile();
      // If now Pro, invite to AI consent.
      final plan = cloud.subscription?.plan ?? cloud.session?.plan;
      if (plan == 'pro' && !cloud.consentEnabled && mounted) {
        final wantConsent = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Enable AI features?'),
            content: const Text(
              'Do you want to allow the AI to analyze your mood data '
              'to offer you personalized insights and advice?\n\n'
              'You can revoke consent at any time from the '
              'settings.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Not now'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Enable'),
              ),
            ],
          ),
        );
        if (wantConsent == true) {
          await cloud.setAiConsent(true);
        }
      }
    } on CloudApiFailure catch (e) {
      setState(() {
        _error = switch (e.code) {
          'plan_invalid' => 'Invalid plan.',
          'network_error' => 'Server unreachable. Check your connection.',
          'auth_error' || 'unauthorized' => 'Authentication failed. Please log in again.',
          _ => 'Error: ${e.code}',
        };
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_error!)),
        );
      }
    } catch (e) {
      setState(() {
        _error = 'An unexpected error occurred. Please try again.';
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_error!)),
        );
      }
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }
}
