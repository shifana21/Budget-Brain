import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/gradient_button.dart';
import '../providers/wallet_provider.dart';

/// Dialog for updating wallet balance.
class WalletUpdateDialog extends ConsumerStatefulWidget {
  const WalletUpdateDialog({super.key});

  @override
  ConsumerState<WalletUpdateDialog> createState() => _WalletUpdateDialogState();
}

class _WalletUpdateDialogState extends ConsumerState<WalletUpdateDialog> {
  final _balanceController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final wallet = ref.read(walletProvider);
    if (wallet != null) {
      _balanceController.text = wallet.initialBalance.toStringAsFixed(2);
    }
  }

  @override
  void dispose() {
    _balanceController.dispose();
    super.dispose();
  }

  Future<void> _updateBalance() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final balance = double.parse(_balanceController.text.trim());
    await ref.read(walletProvider.notifier).updateWallet(balance);

    if (mounted) {
      setState(() => _isLoading = false);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Update Initial Balance'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.edit_rounded,
              size: 48,
              color: AppColors.primary.withValues(alpha: 0.8),
            ),
            const SizedBox(height: 16),
            Text(
              'Update your wallet balance. This will recalculate your remaining balance and savings rate.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _balanceController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'New Balance',
                prefixText: '₹ ',
                prefixIcon: const Icon(Icons.currency_rupee_rounded),
                filled: true,
                fillColor: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.05),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a balance';
                }
                final parsed = double.tryParse(value.trim());
                if (parsed == null || parsed < 0) {
                  return 'Please enter a valid amount';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        GradientButton(
          label: 'Update',
          isLoading: _isLoading,
          onPressed: _updateBalance,
        ),
      ],
    );
  }
}
