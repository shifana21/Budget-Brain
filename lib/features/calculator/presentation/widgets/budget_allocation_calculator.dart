import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../providers/calculator_provider.dart';

/// Budget allocation calculator widget (50/30/20 rule)
class BudgetAllocationCalculator extends ConsumerWidget {
  const BudgetAllocationCalculator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final results = ref.read(calculatorProvider.notifier).calculateBudgetAllocation();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Input Field
          GlassCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Monthly Income',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Enter monthly income',
                    prefixText: '₹ ',
                    filled: true,
                    fillColor: isDark ? AppColors.cardDark : Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) {
                    ref.read(calculatorProvider.notifier).updateMonthlyIncome(
                          double.tryParse(value) ?? 0.0,
                        );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Results
          ...results.asMap().entries.map((entry) {
            final index = entry.key;
            final result = entry.value;
            final colors = [
              AppColors.primary,
              AppColors.secondary,
              AppColors.accent,
            ];
            final icons = [
              Icons.home_rounded,
              Icons.shopping_bag_rounded,
              Icons.savings_rounded,
            ];

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: GlassCard(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: colors[index].withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        icons[index],
                        size: 28,
                        color: colors[index],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            result.label,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${result.unit}${result.value.toStringAsFixed(2)}',
                            style: GoogleFonts.inter(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: colors[index],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          // ignore: unnecessary_to_list_in_spreads
          }).toList(),
          const SizedBox(height: 24),
          // Info Card
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: AppColors.warning,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '50/30/20 Rule: 50% for needs, 30% for wants, 20% for savings',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
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
