import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/database/hive_db_manager.dart';
import 'core/providers/core_providers.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/auth_page.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/dashboard/presentation/main_shell.dart';
import 'features/splash/presentation/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dbManager = HiveDbManager();
  await dbManager.init();

  runApp(
    ProviderScope(
      overrides: [
        dbManagerProvider.overrideWithValue(dbManager),
      ],
      child: const BudgetBrainApp(),
    ),
  );
}

class BudgetBrainApp extends ConsumerWidget {
  const BudgetBrainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'BudgetBrain',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/auth-gate': (context) => const AuthGate(),
      },
    );
  }
}

/// Routes between auth and main shell based on session state.
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authProvider);

    if (session == null) {
      return const AuthPage();
    }

    return const MainShell();
  }
}
