import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:budget_brain/core/theme/app_theme.dart';
import 'package:budget_brain/shared/widgets/gradient_button.dart';

void main() {
  test('Fintech theme palette and chart colors are defined', () {
    expect(AppColors.primary, const Color(0xFF6366F1));
    expect(AppColors.secondary, const Color(0xFF06B6D4));
    expect(AppTheme.chartPalette, isNotEmpty);
  });

  testWidgets('Shared presentation widgets render', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(useMaterial3: true),
        home: Scaffold(
          body: GradientButton(
            label: 'BudgetBrain',
            expanded: false,
            onPressed: () {},
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('BudgetBrain'), findsOneWidget);
  });
}
