import 'package:flutter/material.dart';


import '../../../../core/theme/app_theme.dart';
import '../../../../shared/utils/category_helper.dart';
import '../../domain/entities/transaction.dart';

/// Dialog for adding or editing a transaction.
class TransactionFormDialog extends StatefulWidget {
  const TransactionFormDialog({
    super.key,
    this.existing,
    required this.allTransactions,
    required this.onSave,
  });

  final Transaction? existing;
  final List<Transaction> allTransactions;
  final Future<void> Function(Transaction transaction) onSave;

  @override
  State<TransactionFormDialog> createState() => _TransactionFormDialogState();
}

class _TransactionFormDialogState extends State<TransactionFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _merchantController;
  late final TextEditingController _amountController;
  late final TextEditingController _notesController;
  late String _category;
  late DateTime _date;
  late String _paymentMethod;
  late bool _isRecurring;
  bool _isSaving = false;
  String? _suggestedCategory;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _merchantController = TextEditingController(text: existing?.merchant ?? '');
    _amountController = TextEditingController(
      text: existing != null ? existing.amount.toStringAsFixed(2) : '',
    );
    _notesController = TextEditingController(text: existing?.notes ?? '');
    _category = existing?.category ?? ExpenseCategories.all.first;
    _date = existing?.date ?? DateTime.now();
    _paymentMethod = existing?.paymentMethod ?? 'Card';
    _isRecurring = existing?.isRecurring ?? false;
    _merchantController.addListener(_updateCategoryPreview);
  }

  @override
  void dispose() {
    _merchantController.removeListener(_updateCategoryPreview);
    _merchantController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _updateCategoryPreview() {
    final suggestion = suggestCategoryFromHistory(
      _merchantController.text,
      widget.allTransactions,
    );
    setState(() => _suggestedCategory = suggestion);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    // Generate unique ID using timestamp + random to prevent collisions
    final uniqueId =
        widget.existing?.id ??
        '${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecond}';

    final transaction = Transaction(
      id: uniqueId,
      amount: double.parse(_amountController.text),
      merchant: _merchantController.text.trim(),
      category: _suggestedCategory ?? _category,
      date: _date,
      paymentMethod: _paymentMethod,
      isRecurring: _isRecurring,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );

    await widget.onSave(transaction);

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existing != null;

    return AlertDialog(
      title: Text(isEditing ? 'Edit Transaction' : 'Add Transaction'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _merchantController,
                decoration: const InputDecoration(
                  labelText: 'Merchant',
                  prefixIcon: Icon(Icons.store_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Merchant is required';
                  }
                  return null;
                },
              ),
              if (_suggestedCategory != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.auto_awesome_rounded,
                        size: 16,
                        color: AppColors.accent,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Suggested category: $_suggestedCategory',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.accent,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 12),
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  prefixIcon: Icon(Icons.attach_money_rounded),
                ),
                validator: (value) {
                    final text = value?.trim() ?? '';
                    if (text.isEmpty) {
                      return 'Amount is required';
                    }

                    final parsed = double.tryParse(text);
                    if (parsed == null || parsed <= 0) {
                      return 'Enter a valid amount';
                    }

                    return null;
                  }
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: ExpenseCategories.all
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _category = value);
                },
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Date'),
                subtitle: Text(
                  '${_date.year}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}',
                ),
                trailing: const Icon(Icons.calendar_today_rounded),
                onTap: _pickDate,
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Recurring'),
                value: _isRecurring,
                onChanged: (value) => setState(() => _isRecurring = value),
              ),
              TextFormField(
                controller: _notesController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  prefixIcon: Icon(Icons.notes_outlined),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isSaving ? null : _submit,
          child: _isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(isEditing ? 'Update' : 'Save'),
        ),
      ],
    );
  }
}
