// ignore_for_file: use_build_context_synchronously

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
  final _usernameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _addressController = TextEditingController();

  String? _selectedGender;
  DateTime? _selectedDateOfBirth;
  bool _obscurePassword = true;

  final _formKey = GlobalKey<FormState>();


  bool _normalSignupInProgress = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    _usernameController.dispose();
    _mobileController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  InputDecoration _buildInputDecoration(String labelText) {
    return InputDecoration(
      filled: true,
      fillColor: AppColors.bgSurface,
      labelText: labelText,
      labelStyle: const TextStyle(
        color: AppColors.textSecondary,
      ),
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

  /// Saves the information entered during signup
  /// into the profiles table.
  Future<void> _saveProfileAfterSignup() async {
    // Handled securely by AuthRepositoryImpl during signup
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCanvas,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) async {
          // ---------------------------------------------
          // NORMAL SIGNUP
          // ---------------------------------------------
          if (state is AuthAuthenticated &&
              _normalSignupInProgress) {
            try {
              await _saveProfileAfterSignup();

              if (!mounted) return;

              _normalSignupInProgress = false;

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Account and profile created successfully.',
                  ),
                  backgroundColor: AppColors.dev2Green,
                ),
              );

              if (state.user.kycStatus == 'APPROVED') {
                context.go('/dashboard');
              } else {
                context.go('/kyc-intro');
              }
            } catch (e) {
              if (!mounted) return;

              _normalSignupInProgress = false;

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Account created, but profile could not be saved: $e',
                  ),
                  backgroundColor: Colors.redAccent,
                ),
              );
            }

            return;
          }

          // ---------------------------------------------
          // GOOGLE SIGNUP / LOGIN
          // ---------------------------------------------
          if (state is AuthAuthenticated &&
              !_normalSignupInProgress) {
            if (!mounted) return;

            if (state.user.kycStatus == 'APPROVED') {
              context.go('/dashboard');
            } else {
              context.go('/kyc-intro');
            }

            return;
          }

          // ---------------------------------------------
          // AUTH ERROR
          // ---------------------------------------------
          if (state is AuthError) {
            _normalSignupInProgress = false;

            if (!mounted) return;

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.redAccent,
              ),
            );
          }
        },
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
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

                    // -----------------------------------
                    // FULL NAME
                    // -----------------------------------

                    TextFormField(
                      controller: _fullNameController,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                      ),
                      decoration: _buildInputDecoration(
                        'Full Name *',
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Full name is required';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // -----------------------------------
                    // USERNAME
                    // -----------------------------------

                    TextFormField(
                      controller: _usernameController,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                      ),
                      decoration: _buildInputDecoration(
                        'Unique Username *',
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Username is required';
                        }

                        if (v.contains(' ')) {
                          return 'Spaces are not allowed';
                        }

                        if (v.length < 3) {
                          return 'Username must be at least 3 characters';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // -----------------------------------
                    // EMAIL
                    // -----------------------------------

                    TextFormField(
                      controller: _emailController,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                      ),
                      decoration: _buildInputDecoration(
                        'Email *',
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Email is required';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // -----------------------------------
                    // MOBILE
                    // -----------------------------------

                    TextFormField(
                      controller: _mobileController,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                      ),
                      decoration: _buildInputDecoration(
                        'Mobile Number *',
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Mobile number is required';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // -----------------------------------
                    // PASSWORD
                    // -----------------------------------

                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                      ),
                      decoration:
                          _buildInputDecoration('Password *').copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: AppColors.textSecondary,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword =
                                  !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.length < 6) {
                          return 'Minimum 6 characters';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // -----------------------------------
                    // GENDER
                    // -----------------------------------

                    DropdownButtonFormField<String>(
                      initialValue: _selectedGender,
                      dropdownColor: AppColors.bgSurface,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                      ),
                      decoration: _buildInputDecoration(
                        'Gender',
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'Male',
                          child: Text('Male'),
                        ),
                        DropdownMenuItem(
                          value: 'Female',
                          child: Text('Female'),
                        ),
                        DropdownMenuItem(
                          value: 'Other',
                          child: Text('Other'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedGender = value;
                        });
                      },
                    ),

                    const SizedBox(height: 16),

                    // -----------------------------------
                    // DATE OF BIRTH
                    // -----------------------------------

                    InkWell(
                      onTap: () => _selectDateOfBirth(context),
                      child: InputDecorator(
                        decoration: _buildInputDecoration(
                          'Date of Birth',
                        ),
                        child: Text(
                          _selectedDateOfBirth == null
                              ? 'Select date'
                              : '${_selectedDateOfBirth!.day.toString().padLeft(2, '0')}/'
                                  '${_selectedDateOfBirth!.month.toString().padLeft(2, '0')}/'
                                  '${_selectedDateOfBirth!.year}',
                          style: TextStyle(
                            color: _selectedDateOfBirth == null
                                ? AppColors.textSecondary
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // -----------------------------------
                    // ADDRESS
                    // -----------------------------------

                    TextFormField(
                      controller: _addressController,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                      ),
                      decoration: _buildInputDecoration(
                        'Address',
                      ),
                      maxLines: 2,
                    ),

                    const SizedBox(height: 30),

                    // -----------------------------------
                    // SIGN UP BUTTON
                    // -----------------------------------

                    BlocBuilder<AuthBloc, AuthState>(
                      buildWhen: (previous, current) =>
                          current is AuthLoading ||
                          previous is AuthLoading ||
                          current is AuthInitial,
                      builder: (context, state) {
                        final isLoading =
                            state is AuthLoading;

                        return GreenButton(
                          label: 'Sign Up',
                          isLoading: isLoading,
                          onPressed: () {
                            if (isLoading) return;

                            if (!_formKey.currentState!.validate()) {
                              return;
                            }

                            _normalSignupInProgress = true;

                            context.read<AuthBloc>().add(
                                  AuthSignUpRequested(
                                    email: _emailController.text.trim(),
                                    password:
                                        _passwordController.text.trim(),
                                    fullName:
                                        _fullNameController.text.trim(),
                                    username:
                                        _usernameController.text
                                            .trim()
                                            .toLowerCase(),
                                    mobileNumber:
                                        _mobileController.text.trim(),
                                    gender: _selectedGender,
                                    dateOfBirth:
                                        _selectedDateOfBirth
                                            ?.toIso8601String(),
                                    address:
                                        _addressController.text.trim(),
                                  ),
                                );
                          },
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    // -----------------------------------
                    // GOOGLE SIGNUP
                    // -----------------------------------

                    ElevatedButton.icon(
                      onPressed: () {
                        _normalSignupInProgress = false;

                        context.read<AuthBloc>().add(
                              AuthSignInWithGoogleRequested(),
                            );
                      },
                      icon: const Icon(
                        Icons.g_mobiledata,
                        color: Colors.black,
                      ),
                      label: const Text(
                        'Sign up with Google',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        minimumSize: const Size(
                          double.infinity,
                          50,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // -----------------------------------
                    // LOGIN
                    // -----------------------------------

                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Already have an account? ',
                          style: TextStyle(
                            color:
                                AppColors.textSecondary,
                          ),
                        ),
                        TextButton(
                          onPressed: () =>
                              context.push('/login'),
                          child: const Text(
                            'Sign In',
                            style: TextStyle(
                              color:
                                  AppColors.dev2Green,
                              fontWeight:
                                  FontWeight.bold,
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