import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/utils/formatters.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/goal_progress_widget.dart';
import '../../goals/domain/entities/financial_goal.dart';
import '../../goals/domain/usecases/calculate_goal_requirement_use_case.dart';
import '../../goals/presentation/providers/goal_provider.dart';

/// Goals tab for creating and tracking financial goals.
class GoalsTab extends ConsumerWidget {
  const GoalsTab({super.key});

  Future<void> _showCreateGoalDialog(BuildContext context, WidgetRef ref) async {
    final nameController = TextEditingController();
    final targetController = TextEditingController();
    final currentController = TextEditingController(text: '0');
    DateTime targetDate = DateTime.now().add(const Duration(days: 365));
    final formKey = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Create Goal'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Goal Name'),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: targetController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Target Amount'),
                  validator: (v) {
                    final parsed = double.tryParse(v ?? '');
                    if (parsed == null || parsed <= 0) return 'Invalid amount';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: currentController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration:
                      const InputDecoration(labelText: 'Current Saved'),
                  validator: (v) {
                    final parsed = double.tryParse(v ?? '');
                    if (parsed == null || parsed < 0) return 'Invalid amount';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Target Date'),
                  subtitle: Text(AppFormatters.date.format(targetDate)),
                  trailing: const Icon(Icons.calendar_today_rounded),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: targetDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 3650)),
                    );
                    if (picked != null) {
                      setDialogState(() => targetDate = picked);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;

                final goal = FinancialGoal(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: nameController.text.trim(),
                  targetAmount: double.parse(targetController.text),
                  currentAmount: double.parse(currentController.text),
                  targetDate: targetDate,
                );

                await ref.read(goalProvider.notifier).addGoal(goal);
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );

    nameController.dispose();
    targetController.dispose();
    currentController.dispose();
  }

  Future<void> _showUpdateProgressDialog(
    BuildContext context,
    WidgetRef ref,
    FinancialGoal goal,
  ) async {
    final controller = TextEditingController(
      text: goal.currentAmount.toStringAsFixed(2),
    );

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update "${goal.name}"'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: 'Current Amount Saved'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final amount = double.tryParse(controller.text);
              if (amount != null) {
                await ref
                    .read(goalProvider.notifier)
                    .updateGoalProgress(goal.id, amount);
              }
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );

    controller.dispose();
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    FinancialGoal goal,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Goal'),
        content: Text('Remove "${goal.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(goalProvider.notifier).deleteGoal(goal.id);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goals = ref.watch(goalProvider);
    final calculator = CalculateGoalRequirementUseCase();

    return Stack(
      children: [
        goals.isEmpty
            ? EmptyStateWidget(
                icon: Icons.flag_outlined,
                title: 'No goals yet',
                subtitle: 'Set a savings goal and track your progress.',
                actionLabel: 'Create Goal',
                onAction: () => _showCreateGoalDialog(context, ref),
              )
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                itemCount: goals.length,
                itemBuilder: (context, index) {
                  final goal = goals[index];
                  final monthlyRequired = calculator.call(goal);
                  final remaining =
                      goal.targetAmount - goal.currentAmount;
                  final daysLeft =
                      goal.targetDate.difference(DateTime.now()).inDays;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        GoalProgressWidget(
                          goal: goal,
                          onTap: () =>
                              _showUpdateProgressDialog(context, ref, goal),
                        ),
                        const SizedBox(height: 10),
                        GlassCard(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Savings Calculator',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 10),
                              _InfoRow(
                                label: 'Monthly savings needed',
                                value: AppFormatters.currency
                                    .format(monthlyRequired),
                              ),
                              _InfoRow(
                                label: 'Remaining to save',
                                value:
                                    AppFormatters.currency.format(remaining),
                              ),
                              _InfoRow(
                                label: 'Days until target',
                                value: '$daysLeft days',
                              ),
                              if (monthlyRequired > 0 && daysLeft > 0) ...[
                                const SizedBox(height: 8),
                                Text(
                                  'Forecast: On track if you save ${AppFormatters.currency.format(monthlyRequired)}/month',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: AppColors.accent,
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _showUpdateProgressDialog(
                                  context,
                                  ref,
                                  goal,
                                ),
                                icon: const Icon(Icons.edit_rounded, size: 18),
                                label: const Text('Update Progress'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: () =>
                                  _confirmDelete(context, ref, goal),
                              icon: const Icon(Icons.delete_outline_rounded),
                              color: AppColors.danger,
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
        if (goals.isNotEmpty)
          Positioned(
            right: 16,
            bottom: 16,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 80),
                child: FloatingActionButton.extended(
                  onPressed: () => _showCreateGoalDialog(context, ref),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('New Goal'),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6),
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
