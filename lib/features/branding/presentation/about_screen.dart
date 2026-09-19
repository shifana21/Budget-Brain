import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/glass_card.dart';

/// About screen displaying app information and branding.
class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.secondary],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet_rounded,
                    size: 64,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'BudgetBrain',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your AI-Powered Personal Finance Intelligence System',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.6),
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Version 1.0.0',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Features',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 16),
                _FeatureItem(
                  icon: Icons.receipt_long_rounded,
                  title: 'Expense Tracking',
                  description: 'Track all your expenses with categories and notes',
                ),
                const SizedBox(height: 12),
                _FeatureItem(
                  icon: Icons.auto_graph_rounded,
                  title: 'AI Expense Prediction',
                  description: 'Predict future spending using machine learning',
                ),
                const SizedBox(height: 12),
                _FeatureItem(
                  icon: Icons.warning_rounded,
                  title: 'Anomaly Detection',
                  description: 'Get alerts for unusual spending patterns',
                ),
                const SizedBox(height: 12),
                _FeatureItem(
                  icon: Icons.favorite_rounded,
                  title: 'Financial Health Score',
                  description: 'Comprehensive score based on your habits',
                ),
                const SizedBox(height: 12),
                _FeatureItem(
                  icon: Icons.flag_rounded,
                  title: 'Goal Tracking',
                  description: 'Set and track your financial goals',
                ),
                const SizedBox(height: 12),
                _FeatureItem(
                  icon: Icons.lightbulb_rounded,
                  title: 'AI Recommendations',
                  description: 'Personalized tips to save money',
                ),
                const SizedBox(height: 12),
                _FeatureItem(
                  icon: Icons.smart_toy_rounded,
                  title: 'Financial Chat Assistant',
                  description: 'Ask questions about your finances',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Technology',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 16),
                _TechItem(
                  label: 'Framework',
                  value: 'Flutter',
                ),
                const SizedBox(height: 8),
                _TechItem(
                  label: 'State Management',
                  value: 'Riverpod',
                ),
                const SizedBox(height: 8),
                _TechItem(
                  label: 'Database',
                  value: 'Hive (Offline-first)',
                ),
                const SizedBox(height: 8),
                _TechItem(
                  label: 'Charts',
                  value: 'FL Chart',
                ),
                const SizedBox(height: 8),
                _TechItem(
                  label: 'AI Engine',
                  value: 'Local ML Algorithms',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              'Made with ❤️ for smarter financial management',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.5),
                  ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.6),
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TechItem extends StatelessWidget {
  const _TechItem({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.6),
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}
