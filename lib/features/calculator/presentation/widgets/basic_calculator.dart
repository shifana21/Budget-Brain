import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../providers/calculator_provider.dart';

/// Basic calculator widget
class BasicCalculator extends ConsumerWidget {
  const BasicCalculator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(calculatorProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Display
          GlassCard(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (state.previousValue != null)
                  Text(
                    state.previousValue!,
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      color: isDark ? Colors.white54 : Colors.black54,
                    ),
                  ),
                const SizedBox(height: 8),
                Text(
                  state.display,
                  style: GoogleFonts.inter(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.surfaceDark,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Buttons
          Expanded(
            child: GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildButtonRow(
                    ['C', '÷', '×', '⌫'],
                    isDark,
                    ref,
                  ),
                  const SizedBox(height: 12),
                  _buildButtonRow(
                    ['7', '8', '9', '-'],
                    isDark,
                    ref,
                  ),
                  const SizedBox(height: 12),
                  _buildButtonRow(
                    ['4', '5', '6', '+'],
                    isDark,
                    ref,
                  ),
                  const SizedBox(height: 12),
                  _buildButtonRow(
                    ['1', '2', '3', '%'],
                    isDark,
                    ref,
                  ),
                  const SizedBox(height: 12),
                  _buildButtonRow(
                    ['0', '.', '='],
                    isDark,
                    ref,
                    isLastRow: true,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtonRow(
    List<String> buttons,
    bool isDark,
    WidgetRef ref, {
    bool isLastRow = false,
  }) {
    return Expanded(
      child: Row(
        children: buttons.map((button) {
          final isOperation = ['÷', '×', '-', '+', '%'].contains(button);
          final isSpecial = ['C', '⌫', '='].contains(button);
          final isZero = button == '0';
          final isEquals = button == '=';

          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                right: buttons.indexOf(button) < buttons.length - 1 ? 8 : 0,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: isEquals
                      ? AppColors.primary
                      : isSpecial
                          ? AppColors.warning
                          : isOperation
                              ? AppColors.secondary.withValues(alpha: 0.2)
                              : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ElevatedButton(
                  onPressed: () => _handleButtonPress(button, ref),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: isEquals
                        ? Colors.white
                        : isSpecial
                            ? Colors.white
                            : isDark
                                ? Colors.white
                                : AppColors.surfaceDark,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    button,
                    style: GoogleFonts.inter(
                      fontSize: isZero && !isLastRow ? 32 : 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _handleButtonPress(String button, WidgetRef ref) {
    final notifier = ref.read(calculatorProvider.notifier);

    if (button == 'C') {
      notifier.clear();
    } else if (button == '⌫') {
      notifier.backspace();
    } else if (button == '=') {
      notifier.calculate();
    } else if (['÷', '×', '-', '+', '%'].contains(button)) {
      notifier.inputOperation(button);
    } else {
      notifier.inputNumber(button);
    }
  }
}
