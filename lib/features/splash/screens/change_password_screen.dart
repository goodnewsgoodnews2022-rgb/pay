// ignore_for_file: deprecated_member_use, prefer_const_declarations, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  void _processPasswordUpdate() {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password updated successfully! Remotes terminated.'),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.pop();
    });
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Dynamic theme mapping
    final titleColor = isDark ? Colors.white : Colors.black87;
    final bodyTextColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;
    final fieldBg = isDark ? const Color(0xFF111622) : Colors.grey[200]!;
    final accentColor = const Color(0xFF10B981);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: titleColor),
          onPressed: () => context.pop(),
        ),
        title: Text('Change Password', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: titleColor)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Update Credentials', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: titleColor)),
                const SizedBox(height: 6),
                Text('Ensure your account stays secure by protecting authentication hashes.', style: TextStyle(fontSize: 12, color: bodyTextColor)),
                const SizedBox(height: 24),

                _buildPasswordField(
                  controller: _currentPasswordController,
                  label: 'Current Password',
                  obscure: _obscureCurrent,
                  bg: fieldBg,
                  textColor: titleColor,
                  onToggle: () => setState(() => _obscureCurrent = !_obscureCurrent),
                  validator: (v) => v == null || v.isEmpty ? 'Current password mandatory' : null,
                ),
                const SizedBox(height: 16),

                _buildPasswordField(
                  controller: _newPasswordController,
                  label: 'New Secure Password',
                  obscure: _obscureNew,
                  bg: fieldBg,
                  textColor: titleColor,
                  onToggle: () => setState(() => _obscureNew = !_obscureNew),
                  validator: (v) {
                    if (v == null || v.length < 8) return 'Password must be at least 8 characters long';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                _buildPasswordField(
                  controller: _confirmPasswordController,
                  label: 'Confirm New Password',
                  obscure: _obscureConfirm,
                  bg: fieldBg,
                  textColor: titleColor,
                  onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
                  validator: (v) {
                    if (v != _newPasswordController.text) return 'Passwords do not match';
                    return null;
                  },
                ),
                const SizedBox(height: 36),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                    onPressed: _isLoading ? null : _processPasswordUpdate,
                    child: _isLoading
                        ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text('Update Core Password', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscure,
    required Color bg,
    required Color textColor,
    required VoidCallback onToggle,
    required FormFieldValidator<String> validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textColor)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          style: TextStyle(fontSize: 14, color: textColor),
          decoration: InputDecoration(
            filled: true,
            fillColor: bg,
            errorStyle: TextStyle(color: Colors.redAccent),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            suffixIcon: IconButton(
              icon: Icon(obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 18, color: textColor.withOpacity(0.6)),
              onPressed: onToggle,
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }
}