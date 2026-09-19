import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/gradient_button.dart';
import '../providers/wallet_provider.dart';

/// Dialog for setting up initial wallet balance.
class WalletSetupDialog extends ConsumerStatefulWidget {
  const WalletSetupDialog({super.key});

  @override
  ConsumerState<WalletSetupDialog> createState() => _WalletSetupDialogState();
}

class _WalletSetupDialogState extends ConsumerState<WalletSetupDialog> {
  final _balanceController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _balanceController.dispose();
    super.dispose();
  }

  Future<void> _saveBalance() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final balance = double.parse(_balanceController.text.trim());
    await ref.read(walletProvider.notifier).saveWallet(balance);

    if (mounted) {
      setState(() => _isLoading = false);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Enter Your Current Balance'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.account_balance_wallet_rounded,
              size: 64,
              color: AppColors.primary.withValues(alpha: 0.8),
            ),
            const SizedBox(height: 20),
            Text(
              'Set your initial wallet balance to start tracking your finances.',
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
                labelText: 'Initial Balance',
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
          label: 'Save',
          isLoading: _isLoading,
          onPressed: _saveBalance,
        ),
      ],
    );
  }
}
