// ignore_for_file: unused_import, deprecated_member_use

import 'package:fintech/app/config/app_router.dart';
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
    // 🚀 Load the user's cached biometrics and theme profiles on view mounting
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
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: BlocConsumer<SettingsBloc, SettingsState>(
        listener: (context, state) {
          // 🛡️ Error Interceptor: Alerts the user if data storage fails without crashing the view
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
              child: CircularProgressIndicator(color: AppColors.dev1Silver),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // CARD 0: EDIT PROFILE (Navigation to Profile Sub-system)
              _buildSettingsCard(
                title: 'Edit User Profile',
                subtitle: 'Modify personal info and avatar',
                icon: Icons.person_outline_rounded,
                trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const ProfileScreen()),
                  );
                },
              ),
              const SizedBox(height: 12),

              // CARD 1: BIOMETRIC HANDSHAKE (Fully Wired to state pipeline)
              _buildSettingsCard(
                title: 'Biometric Handshake',
                subtitle: 'Manage FaceID and fingerprint keys',
                icon: Icons.fingerprint,
                trailing: Switch.adaptive(
                  value: state.isBiometricsEnabled, 
                  activeColor: AppColors.dev1Silver,
                  onChanged: (bool value) {
                    context.read<SettingsBloc>().add(ToggleBiometricsRequested(value));
                  }, 
                ),
              ),
              const SizedBox(height: 12),

              // CARD 2: CHANGE TRANSACTION PIN (Feature placeholder)
              _buildSettingsCard(
                title: 'Change Transaction PIN',
                subtitle: 'Authorize security parameters securely',
                icon: Icons.lock_outline,
                trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                onTap: () {
                  // Operational routing track for resetting custom security access code pins
                },
              ),
              const SizedBox(height: 12),

              // CARD 3: APPLICATION DISPLAY MODE (Wired up to state pipeline)
              _buildSettingsCard(
                title: 'Dark Display Mode',
                subtitle: 'Switch application theme mode preference',
                icon: Icons.dark_mode_outlined,
                trailing: Switch.adaptive(
                  value: state.currentTheme == 'dark',
                  activeColor: AppColors.dev1Silver,
                  onChanged: (bool isDark) {
                    context.read<SettingsBloc>().add(ChangeThemeRequested(isDark ? 'dark' : 'light'));
                  },
                ),
              ),
              const SizedBox(height: 32),

              // 🔴 PROFESSIONAL LOGOUT CTA PANEL
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                // Using an inkwell container to keep custom card visual consistency
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () async {
                    // Sign out of active Supabase authentication token streams cleanly
                    await Supabase.instance.client.auth.signOut();
                    if (context.mounted) {
                      // Wipe navigation history stack and re-guard the app viewport
                      context.go('/login'); 
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C141A), // Subtle deep red background tone
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.redAccent.withOpacity(0.3), width: 1),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.logout_rounded, color: Colors.redAccent, size: 20),
                        SizedBox(width: 10),
                        Text(
                          'Secure System Logout',
                          style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 15),
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.dev1Silver.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.dev1Silver),
        ),
        title: Text(title, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        trailing: trailing,
      ),
    );
  }
}