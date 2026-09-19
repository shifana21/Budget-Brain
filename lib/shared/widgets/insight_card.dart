import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../features/ai/domain/entities/insight.dart';
import 'glass_card.dart';

/// Card displaying an AI-generated financial insight.
class InsightCard extends StatelessWidget {
  const InsightCard({
    super.key,
    required this.insight,
  });

  final Insight insight;

  Color get _impactColor {
    if (insight.impactScore >= 0.7) return AppColors.danger;
    if (insight.impactScore >= 0.4) return AppColors.warning;
    return AppColors.accent;
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _impactColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.lightbulb_rounded, color: _impactColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  insight.title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  insight.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.65),
                        height: 1.4,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
