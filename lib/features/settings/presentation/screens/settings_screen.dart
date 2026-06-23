// ignore_for_file: unused_import, deprecated_member_use

import 'package:fintech/app/config/app_router.dart';
import 'package:fintech/app/config/routes/dashboard_routes.dart';
import 'package:fintech/features/KYC/presentation/screens/biometric_setup_screen.dart';
import 'package:fintech/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:fintech/features/authentication/presentation/bloc/auth_event.dart';
import 'package:fintech/features/profile/presentation/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/settings_bloc.dart';
import '../bloc/settings_event.dart';
import '../bloc/settings_state.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SettingsBloc>().add(const LoadSettingsRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCanvas,
      appBar: AppBar(
        backgroundColor: AppColors.bgCanvas,
        elevation: 0,
        title: const Text(
          'Security & Settings',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: BlocConsumer<SettingsBloc, SettingsState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.redAccent,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.dev1Silver,
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // CARD 0: EDIT PROFILE
              _buildSettingsCard(
                title: 'Edit User Profile',
                subtitle: 'Modify personal info and avatar',
                icon: Icons.person_outline_rounded,
                trailing: const Icon(
                  Icons.chevron_right,
                  color: AppColors.textSecondary,
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const ProfileScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),

              // ✅ CARD 1: BIOMETRIC SCAN – now routes to setup screen
              _buildSettingsCard(
                title: 'Biometric Scan',
                subtitle: state.isBiometricsEnabled
                    ? 'Biometrics enabled – tap to change'
                    : 'Add biometrics for quick login',
                icon: Icons.fingerprint,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: state.isBiometricsEnabled
                            ? AppColors.dev2Green.withOpacity(0.2)
                            : AppColors.textSecondary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        state.isBiometricsEnabled ? 'Enabled' : 'Disabled',
                        style: TextStyle(
                          color: state.isBiometricsEnabled
                              ? AppColors.dev2Green
                              : AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.chevron_right,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
                // Inside the biometric card's onTap:
                onTap: () async {
                  await context.push(
                    '/biometric-setup',
                    extra: state.isBiometricsEnabled,
                  );
                  // Reload settings to reflect the updated biometric state
                  context.read<SettingsBloc>().add(
                    const LoadSettingsRequested(),
                  );
                },
              ),
              const SizedBox(height: 12),

              // CARD 2: CHANGE TRANSACTION PIN
              _buildSettingsCard(
                title: 'Change Transaction PIN',
                subtitle: 'Authorize security parameters securely',
                icon: Icons.lock_outline,
                trailing: const Icon(
                  Icons.chevron_right,
                  color: AppColors.textSecondary,
                ),
                onTap: () {
                  // You can later navigate to a PIN change screen
                  // For now, go to PIN setup as a placeholder
                  context.go('/pin-setup');
                },
              ),
              const SizedBox(height: 12),

              // CARD 3: DARK MODE
              _buildSettingsCard(
                title: 'Dark Display Mode',
                subtitle: 'Switch application theme mode preference',
                icon: Icons.dark_mode_outlined,
                trailing: Switch.adaptive(
                  value: state.currentTheme == 'dark',
                  activeColor: AppColors.dev1Silver,
                  onChanged: (bool isDark) {
                    context.read<SettingsBloc>().add(
                      ChangeThemeRequested(isDark ? 'dark' : 'light'),
                    );
                  },
                ),
              ),
              const SizedBox(height: 32),

              // LOGOUT BUTTON
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    // ✅ Dispatch signout event to AuthBloc
                    context.read<AuthBloc>().add(AuthSignOutRequested());
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C141A),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.redAccent.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.logout_rounded,
                          color: Colors.redAccent,
                          size: 20,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Secure System Logout',
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSettingsCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 4,
        ),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.dev1Silver.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.dev1Silver),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
        trailing: trailing,
      ),
    );
  }
}
