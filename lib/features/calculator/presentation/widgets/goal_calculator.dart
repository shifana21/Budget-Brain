import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../providers/calculator_provider.dart';

/// Goal calculator widget
class GoalCalculator extends ConsumerWidget {
  const GoalCalculator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.read(calculatorProvider.notifier).calculateRequiredMonthlySavings();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Input Fields
          GlassCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Goal Amount',
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
                    hintText: 'Enter goal amount',
                    prefixText: '₹ ',
                    filled: true,
                    fillColor: isDark ? AppColors.cardDark : Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) {
                    ref.read(calculatorProvider.notifier).updateGoalAmount(
                          double.tryParse(value) ?? 0.0,
                        );
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  'Current Amount',
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
                    hintText: 'Enter current amount',
                    prefixText: '₹ ',
                    filled: true,
                    fillColor: isDark ? AppColors.cardDark : Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) {
                    ref.read(calculatorProvider.notifier).updateCurrentAmount(
                          double.tryParse(value) ?? 0.0,
                        );
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  'Months Remaining',
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
                    hintText: 'Enter months remaining',
                    filled: true,
                    fillColor: isDark ? AppColors.cardDark : Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) {
                    ref.read(calculatorProvider.notifier).updateMonthsRemaining(
                          int.tryParse(value) ?? 12,
                        );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Result
          GlassCard(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Icon(
                  Icons.flag_rounded,
                  size: 48,
                  color: AppColors.accent,
                ),
                const SizedBox(height: 16),
                Text(
                  result.label,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${result.unit}${result.value.toStringAsFixed(2)}',
                  style: GoogleFonts.inter(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'per month',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: isDark ? Colors.white54 : Colors.black54,
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
