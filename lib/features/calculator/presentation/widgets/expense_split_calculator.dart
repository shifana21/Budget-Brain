import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../providers/calculator_provider.dart';

/// Expense split calculator widget
class ExpenseSplitCalculator extends ConsumerWidget {
  const ExpenseSplitCalculator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(calculatorProvider);
    final result = ref.read(calculatorProvider.notifier).calculateExpensePerPerson();
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
                  'Total Expense',
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
                    hintText: 'Enter total expense',
                    prefixText: '₹ ',
                    filled: true,
                    fillColor: isDark ? AppColors.cardDark : Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) {
                    ref.read(calculatorProvider.notifier).updateTotalExpense(
                          double.tryParse(value) ?? 0.0,
                        );
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  'Number of People',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'Enter number of people',
                          filled: true,
                          fillColor: isDark ? AppColors.cardDark : Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: (value) {
                          ref.read(calculatorProvider.notifier).updateNumberOfPeople(
                                int.tryParse(value) ?? 2,
                              );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      onPressed: () {
                        ref.read(calculatorProvider.notifier).updateNumberOfPeople(
                              state.numberOfPeople + 1,
                            );
                      },
                      icon: const Icon(Icons.add),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () {
                        if (state.numberOfPeople > 1) {
                          ref.read(calculatorProvider.notifier).updateNumberOfPeople(
                                state.numberOfPeople - 1,
                              );
                        }
                      },
                      icon: const Icon(Icons.remove),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.danger,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
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
                  Icons.people_rounded,
                  size: 48,
                  color: AppColors.secondary,
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
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'for ${state.numberOfPeople} ${state.numberOfPeople == 1 ? "person" : "people"}',
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
