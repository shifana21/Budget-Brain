import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../providers/calculator_provider.dart';

/// EMI calculator widget
class EMICalculator extends ConsumerWidget {
  const EMICalculator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.read(calculatorProvider.notifier).calculateEMI();
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
                  'Loan Amount',
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
                    hintText: 'Enter loan amount',
                    prefixText: '₹ ',
                    filled: true,
                    fillColor: isDark ? AppColors.cardDark : Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) {
                    ref.read(calculatorProvider.notifier).updateLoanAmount(
                          double.tryParse(value) ?? 0.0,
                        );
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  'Interest Rate (% per annum)',
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
                    hintText: 'Enter interest rate',
                    suffixText: '%',
                    filled: true,
                    fillColor: isDark ? AppColors.cardDark : Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) {
                    ref.read(calculatorProvider.notifier).updateInterestRate(
                          double.tryParse(value) ?? 0.0,
                        );
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  'Tenure (Months)',
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
                    hintText: 'Enter tenure in months',
                    filled: true,
                    fillColor: isDark ? AppColors.cardDark : Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) {
                    ref.read(calculatorProvider.notifier).updateTenureMonths(
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
                  Icons.account_balance_rounded,
                  size: 48,
                  color: AppColors.warning,
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
                    color: AppColors.warning,
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
