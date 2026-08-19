import 'package:application/app/theme/app_colors.dart';
import 'package:application/services/ai_controller.dart';
import 'package:application/services/auth_api_client.dart';
import 'package:application/state/cloud_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Full-screen weekly/monthly insights.
class InsightsPage extends StatefulWidget {
  const InsightsPage({super.key});

  @override
  State<InsightsPage> createState() => _InsightsPageState();
}

class _InsightsPageState extends State<InsightsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final controller = context.read<AiController>();
    final cloud = context.read<CloudController>();
    final session = cloud.session;
    if (session == null) return;
    await controller.loadInsights(
      baseUrl: apiBaseUrl(),
      accessToken: session.accessToken,
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AiController>();
    final insights = controller.insights;

    return Scaffold(
      appBar: AppBar(title: const Text('Insights')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: insights.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text(
                      'No insights available yet. Insights are '
                      'periodically generated from your data.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textFaint),
                    ),
                  ),
                )
              : ListView.builder(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
                  itemCount: insights.length,
                  itemBuilder: (_, i) {
                    final insight = insights[i];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surface.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.insights_rounded, color: AppColors.accent, size: 20),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  insight.kind == 'weekly' ? 'WEEKLY ANALYSIS' : 'MONTHLY ANALYSIS',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 10,
                                    letterSpacing: 1.2,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  insight.content,
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    height: 1.5,
                                    fontSize: 14.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
