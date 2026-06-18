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
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _addressController = TextEditingController();
  String? _selectedGender;
  DateTime? _selectedDateOfBirth;

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    _mobileController.dispose();
    _addressController.dispose();
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

  Future<void> _selectDateOfBirth(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000, 1, 1),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.dev2Green,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDateOfBirth = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCanvas,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            final user = state.user;
            if (user.kycStatus == 'verified'){
              context.go('/dashboard');
              return;
            }
             context.go('/kyc-intro');
             return;
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
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
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
                    const SizedBox(height: 30),

                    TextFormField(
                      controller: _fullNameController,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: _buildInputDecoration('Full Name *'),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _emailController,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: _buildInputDecoration('Email *'),
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _mobileController,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: _buildInputDecoration('Mobile Number *'),
                      keyboardType: TextInputType.phone,
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: _buildInputDecoration('Password *'),
                      validator: (v) => v == null || v.length < 6
                          ? 'Minimum 6 characters'
                          : null,
                    ),
                    const SizedBox(height: 16),

                    DropdownButtonFormField<String>(
                      // ignore: deprecated_member_use
                      value: _selectedGender,
                      dropdownColor: AppColors.bgSurface,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: _buildInputDecoration('Gender'),
                      items: ['Male', 'Female', 'Other']
                          .map(
                            (g) =>
                                DropdownMenuItem(value: g, child: Text(g)),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _selectedGender = value),
                    ),
                    const SizedBox(height: 16),

                    InkWell(
                      onTap: () => _selectDateOfBirth(context),
                      child: InputDecorator(
                        decoration: _buildInputDecoration('Date of Birth'),
                        child: Text(
                          _selectedDateOfBirth == null
                              ? 'Select date'
                              : '${_selectedDateOfBirth!.day}/${_selectedDateOfBirth!.month}/${_selectedDateOfBirth!.year}',
                          style: TextStyle(
                            color: _selectedDateOfBirth == null
                                ? AppColors.textSecondary
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _addressController,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: _buildInputDecoration('Address'),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 30),

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
                            if (_formKey.currentState!.validate()) {
                              context.read<AuthBloc>().add(
                                AuthSignUpRequested(
                                  email: _emailController.text.trim(),
                                  password: _passwordController.text
                                      .trim(),
                                  fullName: _fullNameController.text
                                      .trim(),
                                  mobileNumber: _mobileController.text
                                      .trim(),
                                  gender: _selectedGender,
                                  dateOfBirth: _selectedDateOfBirth
                                      ?.toIso8601String(),
                                  address: _addressController.text.trim(),
                                ),
                              );
                            }
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
        ),
      ),
    );
  }
}
