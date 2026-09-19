import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../features/transactions/domain/entities/transaction.dart';
import '../utils/formatters.dart';

/// List tile for displaying a transaction.
class TransactionTile extends StatelessWidget {
  const TransactionTile({
    super.key,
    required this.transaction,
    this.onTap,
    this.onDelete,
  });

  final Transaction transaction;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  IconData get _categoryIcon {
    switch (transaction.category.toLowerCase()) {
      case 'food':
        return Icons.restaurant_rounded;
      case 'transport':
        return Icons.directions_car_rounded;
      case 'shopping':
        return Icons.shopping_bag_rounded;
      case 'utilities':
        return Icons.bolt_rounded;
      case 'entertainment':
        return Icons.movie_rounded;
      case 'health':
        return Icons.favorite_rounded;
      case 'education':
        return Icons.school_rounded;
      case 'travel':
        return Icons.flight_rounded;
      default:
        return Icons.receipt_long_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_categoryIcon, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.merchant,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${transaction.category} · ${AppFormatters.shortDate.format(transaction.date)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.55),
                          ),
                    ),
                  ],
                ),
              ),
              Text(
                '-${AppFormatters.currency.format(transaction.amount)}',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.danger,
                    ),
              ),
              if (onDelete != null) ...[
                const SizedBox(width: 4),
                IconButton(
                  icon: Icon(
                    Icons.delete_outline_rounded,
                    size: 20,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.4),
                  ),
                  onPressed: onDelete,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
