import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/gradient_button.dart';
import 'providers/auth_provider.dart';

/// Authentication screen with login, signup, and guest access.
class AuthPage extends ConsumerStatefulWidget {
  const AuthPage({super.key});

  @override
  ConsumerState<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends ConsumerState<AuthPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _loginFormKey = GlobalKey<FormState>();
  final _signupFormKey = GlobalKey<FormState>();

  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  final _signupUsernameController = TextEditingController();
  final _signupEmailController = TextEditingController();
  final _signupPasswordController = TextEditingController();
  final _signupConfirmController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;
  bool _loginPasswordVisible = false;
  bool _signupPasswordVisible = false;
  bool _signupConfirmVisible = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _signupUsernameController.dispose();
    _signupEmailController.dispose();
    _signupPasswordController.dispose();
    _signupConfirmController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_loginFormKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await ref.read(authProvider.notifier).login(
            _loginEmailController.text.trim(),
            _loginPasswordController.text,
          );
    } catch (e) {
      setState(() => _errorMessage = 'Login failed. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSignup() async {
    if (!_signupFormKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await ref.read(authProvider.notifier).signup(
            _signupUsernameController.text.trim(),
            _signupEmailController.text.trim(),
            _signupPasswordController.text,
          );
    } catch (e) {
      setState(() => _errorMessage = 'Signup failed. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleGuest() {
    ref.read(authProvider.notifier).loginAsGuest();
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
                ? [AppColors.surfaceDark, const Color(0xFF1E1B4B)]
                : [const Color(0xFFEEF2FF), const Color(0xFFECFEFF)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.secondary],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.4),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet_rounded,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'BudgetBrain',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Smart finance. Powered by AI.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.6),
                          ),
                    ),
                    const SizedBox(height: 32),
                    GlassCard(
                      child: Column(
                        children: [
                          TabBar(
                            controller: _tabController,
                            indicatorColor: AppColors.primary,
                            labelColor: AppColors.primary,
                            unselectedLabelColor: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.5),
                            tabs: const [
                              Tab(text: 'Login'),
                              Tab(text: 'Sign Up'),
                            ],
                          ),
                          const SizedBox(height: 20),
                          if (_errorMessage != null) ...[
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.danger.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                _errorMessage!,
                                style: TextStyle(
                                  color: AppColors.danger,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                          AnimatedSize(
                            duration: const Duration(milliseconds: 300),
                            child: SizedBox(
                              height: _tabController.index == 0 ? 220 : 320,
                              child: TabBarView(
                                controller: _tabController,
                                children: [
                                  _buildLoginForm(),
                                  _buildSignupForm(),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          GradientButton(
                            label: _tabController.index == 0 ? 'Sign In' : 'Create Account',
                            isLoading: _isLoading,
                            onPressed: _tabController.index == 0
                                ? _handleLogin
                                : _handleSignup,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: _isLoading ? null : _handleGuest,
                      child: const Text('Continue as Guest'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _loginFormKey,
      child: Column(
        children: [
          TextFormField(
            controller: _loginEmailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email_outlined),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Email is required';
              }
              if (!value.contains('@')) return 'Enter a valid email';
              return null;
            },
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _loginPasswordController,
            obscureText: !_loginPasswordVisible,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  _loginPasswordVisible ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _loginPasswordVisible = !_loginPasswordVisible;
                  });
                },
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Password is required';
              if (value.length < 6) return 'Minimum 6 characters';
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSignupForm() {
    return Form(
      key: _signupFormKey,
      child: Column(
        children: [
          TextFormField(
            controller: _signupUsernameController,
            decoration: const InputDecoration(
              labelText: 'Username',
              prefixIcon: Icon(Icons.person_outline),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Username is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _signupEmailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email_outlined),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Email is required';
              }
              if (!value.contains('@')) return 'Enter a valid email';
              return null;
            },
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _signupPasswordController,
            obscureText: !_signupPasswordVisible,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  _signupPasswordVisible ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _signupPasswordVisible = !_signupPasswordVisible;
                  });
                },
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Password is required';
              if (value.length < 6) return 'Minimum 6 characters';
              return null;
            },
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _signupConfirmController,
            obscureText: !_signupConfirmVisible,
            decoration: InputDecoration(
              labelText: 'Confirm Password',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  _signupConfirmVisible ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _signupConfirmVisible = !_signupConfirmVisible;
                  });
                },
              ),
            ),
            validator: (value) {
              if (value != _signupPasswordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}
