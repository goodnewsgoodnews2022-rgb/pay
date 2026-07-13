// lib/features/admin/presentation/screens/admin_broadcast_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/admin_bloc.dart';
import '../bloc/admin_event.dart';
import '../bloc/admin_state.dart';

class AdminBroadcastScreen extends StatefulWidget {
  const AdminBroadcastScreen({super.key});

  @override
  State<AdminBroadcastScreen> createState() =>
      _AdminBroadcastScreenState();
}

class _AdminBroadcastScreenState extends State<AdminBroadcastScreen> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCanvas,
      appBar: AppBar(
        backgroundColor: AppColors.bgSurface,
        title: const Text(
          'Send Broadcast',
          style: TextStyle(color: AppColors.textPrimary),
        ),
      ),
      body: BlocConsumer<AdminBloc, AdminState>(
        listener: (context, state) {
          if (state is AdminOperationSuccess) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
            _titleController.clear();
            _bodyController.clear();
            _formKey.currentState?.reset();
          }
          if (state is AdminError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.error)));
          }
        },
        builder: (context, state) {
          final isLoading = state is AdminLoading;
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Send a notification to all users',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _titleController,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: const InputDecoration(
                      labelText: 'Title *',
                      labelStyle: TextStyle(
                        color: AppColors.textSecondary,
                      ),
                      filled: true,
                      fillColor: AppColors.bgSurface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(12),
                        ),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (v) => v == null || v.isEmpty
                        ? 'Title is required'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _bodyController,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: const InputDecoration(
                      labelText: 'Message *',
                      labelStyle: TextStyle(
                        color: AppColors.textSecondary,
                      ),
                      filled: true,
                      fillColor: AppColors.bgSurface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(12),
                        ),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    maxLines: 5,
                    validator: (v) => v == null || v.isEmpty
                        ? 'Message is required'
                        : null,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              if (_formKey.currentState!.validate()) {
                                context.read<AdminBloc>().add(
                                  SendBroadcastNotificationEvent(
                                    _titleController.text,
                                    _bodyController.text,
                                  ),
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.dev1Silver,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator(
                              color: Colors.black,
                            )
                          : const Text('Send Broadcast'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
