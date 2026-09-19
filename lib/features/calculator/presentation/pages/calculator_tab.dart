import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../widgets/basic_calculator.dart';
import '../widgets/savings_calculator.dart';
import '../widgets/goal_calculator.dart';
import '../widgets/emi_calculator.dart';
import '../widgets/expense_split_calculator.dart';
import '../widgets/budget_allocation_calculator.dart';

/// Calculator tab with multiple financial calculators
class CalculatorTab extends ConsumerStatefulWidget {
  const CalculatorTab({super.key});

  @override
  ConsumerState<CalculatorTab> createState() => _CalculatorTabState();
}

class _CalculatorTabState extends ConsumerState<CalculatorTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [AppColors.surfaceDark, AppColors.cardDark]
                : [AppColors.surfaceLight, Colors.white],
          ),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    'Finance Calculator',
                    style: GoogleFonts.inter(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.surfaceDark,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Tab Bar
                  GlassCard(
                    child: TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      indicatorColor: AppColors.primary,
                      labelColor: AppColors.primary,
                      unselectedLabelColor: isDark ? Colors.white54 : Colors.black54,
                      labelStyle: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      unselectedLabelStyle: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      tabs: const [
                        Tab(text: 'Basic'),
                        Tab(text: 'Savings'),
                        Tab(text: 'Goal'),
                        Tab(text: 'EMI'),
                        Tab(text: 'Split'),
                        Tab(text: 'Budget'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [
                  BasicCalculator(),
                  SavingsCalculator(),
                  GoalCalculator(),
                  EMICalculator(),
                  ExpenseSplitCalculator(),
                  BudgetAllocationCalculator(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
