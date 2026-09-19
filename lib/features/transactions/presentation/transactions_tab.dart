import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/utils/category_helper.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/transaction_tile.dart';
import '../../transactions/domain/entities/transaction.dart';
import '../../transactions/presentation/providers/transaction_provider.dart';
import 'widgets/transaction_form_dialog.dart';

/// Transactions tab with search, filter, and CRUD operations.
class TransactionsTab extends ConsumerStatefulWidget {
  const TransactionsTab({super.key});

  @override
  ConsumerState<TransactionsTab> createState() => _TransactionsTabState();
}

class _TransactionsTabState extends ConsumerState<TransactionsTab> {
  final _searchController = TextEditingController();
  String? _selectedCategory;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Transaction> _filteredTransactions(List<Transaction> transactions) {
    final query = _searchController.text.trim().toLowerCase();

    return transactions.where((tx) {
      final matchesSearch = query.isEmpty ||
          tx.merchant.toLowerCase().contains(query) ||
          tx.category.toLowerCase().contains(query) ||
          (tx.notes?.toLowerCase().contains(query) ?? false);

      final matchesCategory =
          _selectedCategory == null || tx.category == _selectedCategory;

      return matchesSearch && matchesCategory;
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> _showTransactionDialog({Transaction? existing}) async {
    final transactions = ref.read(transactionProvider);
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => TransactionFormDialog(
        existing: existing,
        allTransactions: transactions,
        onSave: (Transaction transaction) async {
          final notifier = ref.read(transactionProvider.notifier);
          if (existing != null) {
            await notifier.deleteTransaction(existing.id);
          }
          await notifier.addTransaction(transaction);

          // Show snackbar feedback
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  existing != null
                      ? 'Transaction updated successfully'
                      : 'Transaction added successfully',
                ),
                duration: const Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
      ),
    );
  }

  Future<void> _confirmDelete(Transaction transaction) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: Text('Remove "${transaction.merchant}"?'),
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
      await ref.read(transactionProvider.notifier).deleteTransaction(transaction.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final transactions = ref.watch(transactionProvider);
    final filtered = _filteredTransactions(transactions);
    final categories = {
      ...ExpenseCategories.all,
      ...transactions.map((tx) => tx.category),
    }.toList()
      ..sort();

    return Stack(
      children: [
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Search transactions...',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {});
                              },
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 38,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: const Text('All'),
                            selected: _selectedCategory == null,
                            onSelected: (_) =>
                                setState(() => _selectedCategory = null),
                          ),
                        ),
                        ...categories.map(
                          (category) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(category),
                              selected: _selectedCategory == category,
                              onSelected: (_) => setState(
                                () => _selectedCategory = category,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: filtered.isEmpty
                  ? EmptyStateWidget(
                      icon: Icons.receipt_long_outlined,
                      title: transactions.isEmpty
                          ? 'No transactions yet'
                          : 'No matches found',
                      subtitle: transactions.isEmpty
                          ? 'Tap + to add your first expense.'
                          : 'Try adjusting your search or filters.',
                      actionLabel: transactions.isEmpty ? 'Add Transaction' : null,
                      onAction: transactions.isEmpty
                          ? () => _showTransactionDialog()
                          : null,
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                      itemCount: filtered.length,
                      itemExtent: 72,
                      itemBuilder: (context, index) {
                        final tx = filtered[index];
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: GlassCard(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 2,
                              ),
                              child: TransactionTile(
                                transaction: tx,
                                onTap: () => _showTransactionDialog(existing: tx),
                                onDelete: () => _confirmDelete(tx),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
        if (filtered.isNotEmpty)
          Positioned(
            right: 16,
            bottom: 16,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 80),
                child: FloatingActionButton.extended(
                  onPressed: () => _showTransactionDialog(),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Add'),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
