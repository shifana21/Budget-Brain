import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../ai/presentation/chat_tab.dart';
import '../../analytics/presentation/analytics_tab.dart';
import '../../auth/presentation/providers/auth_provider.dart';
import '../../calculator/presentation/pages/calculator_tab.dart';
import '../../dashboard/presentation/dashboard_tab.dart';
import '../../goals/presentation/goals_tab.dart';
import '../../transactions/presentation/transactions_tab.dart';
import '../../branding/presentation/about_screen.dart';
import '../../wallet/presentation/widgets/wallet_update_dialog.dart';

/// Main app shell with bottom navigation across six tabs.
class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _currentIndex = 0;

  static const _tabs = [
    DashboardTab(),
    TransactionsTab(),
    AnalyticsTab(),
    GoalsTab(),
    CalculatorTab(),
    ChatTab(),
  ];

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(authProvider);
    final username = session?.username ?? 'User';

    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _tabTitle(_currentIndex),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              'Hello, $username',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.5),
                  ),
            ),
          ],
        ),
        actions: [
          if (session?.isGuest == true)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Chip(
                label: const Text('Guest', style: TextStyle(fontSize: 11)),
                visualDensity: VisualDensity.compact,
              ),
            ),
          IconButton(
            icon: const Icon(Icons.account_balance_wallet_rounded),
            tooltip: 'Update Balance',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const WalletUpdateDialog(),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.info_outline_rounded),
            tooltip: 'About',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Logout',
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
            },
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        child: KeyedSubtree(
          key: ValueKey(_currentIndex),
          child: _tabs[_currentIndex],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long_rounded),
            label: 'Transactions',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics_outlined),
            selectedIcon: Icon(Icons.analytics_rounded),
            label: 'Analytics',
          ),
          NavigationDestination(
            icon: Icon(Icons.flag_outlined),
            selectedIcon: Icon(Icons.flag_rounded),
            label: 'Goals',
          ),
          NavigationDestination(
            icon: Icon(Icons.calculate_outlined),
            selectedIcon: Icon(Icons.calculate_rounded),
            label: 'Calculator',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_outlined),
            selectedIcon: Icon(Icons.chat_rounded),
            label: 'AI Chat',
          ),
        ],
      ),
    );
  }

  String _tabTitle(int index) {
    return switch (index) {
      0 => 'Dashboard',
      1 => 'Transactions',
      2 => 'Analytics',
      3 => 'Goals',
      4 => 'Calculator',
      5 => 'AI Advisor',
      _ => 'BudgetBrain',
    };
  }
}
