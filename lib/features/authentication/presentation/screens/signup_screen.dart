import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/green_button.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _fullNameController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _fullNameController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    super.dispose();
  }

  InputDecoration _buildInputDecoration(String labelText) {
    return InputDecoration(
      filled: true,
      fillColor: AppColors.bgSurface,
      labelText: labelText,
      labelStyle: const TextStyle(color: AppColors.textSecondary),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: AppColors.dev2Green,
          width: 1.5,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCanvas,
      // 1. PLACE LISTENER AT THE TOP: Handles one-time action side effects cleanly
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            context.go('/dashboard');
          }
          if (state is AuthError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 40),

                // These inputs are static and will NEVER undergo redundant redraw allocations
                TextField(
                  controller: _fullNameController,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: _buildInputDecoration('Full Name'),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _emailController,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: _buildInputDecoration('Email'),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: _buildInputDecoration('Password'),
                ),
                const SizedBox(height: 30),

                // 2. SCOPE YOUR BUILDER: Wrap only the UI target that alters layout states
                BlocBuilder<AuthBloc, AuthState>(
                  buildWhen: (previous, current) =>
                      current is AuthLoading ||
                      previous is AuthLoading ||
                      current is AuthInitial,
                  builder: (context, state) {
                    final isLoading = state is AuthLoading;

                    return GreenButton(
                      label: 'Sign Up',
                      isLoading: isLoading,
                      onPressed: () {
                        context.read<AuthBloc>().add(
                          AuthSignUpRequested(
                            _emailController.text.trim(),
                            _passwordController.text.trim(),
                            _fullNameController.text.trim(),
                          ),
                        );
                      },
                    );
                  },
                ),

                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Already have an account? ",
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    TextButton(
                      onPressed: () => context.push('/login'),
                      child: const Text(
                        'Sign In',
                        style: TextStyle(
                          color: AppColors.dev2Green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
