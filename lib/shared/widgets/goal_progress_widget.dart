import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../features/goals/domain/entities/financial_goal.dart';
import '../utils/formatters.dart';
import 'glass_card.dart';

/// Progress card for a single financial goal.
class GoalProgressWidget extends StatelessWidget {
  const GoalProgressWidget({
    super.key,
    required this.goal,
    this.onTap,
    this.compact = false,
  });

  final FinancialGoal goal;
  final VoidCallback? onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final progress = goal.targetAmount > 0
        ? (goal.currentAmount / goal.targetAmount).clamp(0.0, 1.0)
        : 0.0;
    final remaining = (goal.targetDate.difference(DateTime.now()).inDays)
        .clamp(0, 9999);

    return GlassCard(
      onTap: onTap,
      padding: EdgeInsets.all(compact ? 14 : 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.flag_rounded, color: AppColors.primary, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  goal.name,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${(progress * 100).toStringAsFixed(0)}%',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: compact ? 6 : 8,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              color: AppColors.accent,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppFormatters.currency.format(goal.currentAmount),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                AppFormatters.currency.format(goal.targetAmount),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.6),
                    ),
              ),
            ],
          ),
          if (!compact) ...[
            const SizedBox(height: 6),
            Text(
              '$remaining days remaining',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.5),
                  ),
            ),
          ],
        ],
      ),
    );
  }
}
