// ignore_for_file: unused_field, deprecated_member_use, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart'; // Import package

class ReportProblemScreen extends StatefulWidget {
  const ReportProblemScreen({super.key});

  @override
  State<ReportProblemScreen> createState() => _ReportProblemScreenState();
}

class _ReportProblemScreenState extends State<ReportProblemScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _transactionIdController = TextEditingController();
  final ImagePicker _picker = ImagePicker(); // Initialize ImagePicker inside state
  
  String? _selectedCategory;
  bool _isSubmitting = false;
  String? _attachedFileName;
  String? _attachedFilePath; // Optional: Stores full file system path for upload APIs

  // List of problem categories for the dropdown menu
  final List<String> _problemCategories = [
    'Failed transactions',
    'Incorrect charges',
    'App crashes or bugs',
    'Account access issues',
    'Other technical problems',
  ];

  // Method to open native gallery picker channel
  Future<void> _pickScreenshotFromGallery() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85, // Optimizes compression size footprint before sending to backend
      );

      if (pickedFile != null) {
        setState(() {
          _attachedFileName = pickedFile.name; // Extracts file image name string (e.g. IMG_2026.png)
          _attachedFilePath = pickedFile.path; // Holds reference path for form multi-part payloads
        });
        
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Screenshot attached successfully'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xFF10B981),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to access device gallery permissions'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _submitTicket() {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    // Simulate backend logging lifecycle 
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
      });

      _showSuccessDialog();
    });
  }

  void _showSuccessDialog() {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: theme.brightness == Brightness.dark ? const Color(0xFF151424) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.check_circle_rounded, color: const Color(0xFF10B981)),
            const SizedBox(width: 8),
            Text('Ticket Submitted', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          'Your support ticket has been created successfully. Our engineering team is reviewing it and will notify you within 12 hours.',
          style: TextStyle(fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              context.pop(); // Go back to Support Center Screen
            },
            child: Text('Done', style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _transactionIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardBgColor = isDark ? const Color(0xFF151424) : Colors.grey[50];
    final inputBgColor = isDark ? const Color(0xFF0A0A10) : Colors.white;
    final cardBorderColor = isDark ? const Color(0xFF26243C) : Colors.grey[200]!;
    final accentPrimaryColor = theme.colorScheme.primary != theme.scaffoldBackgroundColor 
        ? theme.colorScheme.primary 
        : const Color(0xFF8B5CF6);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Report a Problem',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: theme.colorScheme.onSurface),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Submit a Support Ticket',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Encountered an anomaly? Let us know right away so our technical team can trace and fix the issue.',
                    style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[400] : Colors.grey[600], height: 1.4),
                  ),
                  const SizedBox(height: 24),

                  // ====================================================================
                  // PROBLEM CATEGORY DROPDOWN MENU
                  // ====================================================================
                  Text('What issue are you experiencing?', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    hint: Text('Select problem category', style: TextStyle(fontSize: 14, color: Colors.grey)),
                    dropdownColor: cardBgColor,
                    style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: inputBgColor,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: cardBorderColor)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: accentPrimaryColor, width: 1.5)),
                      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.redAccent)),
                      focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.redAccent, width: 1.5)),
                    ),
                    items: _problemCategories.map((category) {
                      return DropdownMenuItem(value: category, child: Text(category));
                    }).toList(),
                    validator: (value) => value == null ? 'Please select a category' : null,
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    },
                  ),
                  const SizedBox(height: 20),

                  // ====================================================================
                  // CONDITIONAL TRANSACTION ID FIELD (Shows for financial issues)
                  // ====================================================================
                  if (_selectedCategory == 'Failed transactions' || _selectedCategory == 'Incorrect charges') ...[
                    Text('Transaction Reference ID (Optional)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _transactionIdController,
                      style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface),
                      decoration: InputDecoration(
                        hintText: 'e.g. TXN-98231-PAY',
                        hintStyle: TextStyle(fontSize: 13, color: Colors.grey),
                        filled: true,
                        fillColor: inputBgColor,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: cardBorderColor)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: accentPrimaryColor, width: 1.5)),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // ====================================================================
                  // DETAILED DESCRIPTION INPUT FIELD
                  // ====================================================================
                  Text('Explain what happened', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 5,
                    maxLength: 500,
                    style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface),
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: 'Provide detailed behavior (steps to reproduce, errors seen, exact amounts missing, etc.)...',
                      hintStyle: TextStyle(fontSize: 13, color: Colors.grey, height: 1.4),
                      filled: true,
                      fillColor: inputBgColor,
                      counterStyle: TextStyle(fontSize: 11),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: cardBorderColor)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: accentPrimaryColor, width: 1.5)),
                      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.redAccent)),
                      focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.redAccent, width: 1.5)),
                    ),
                    validator: (value) => value == null || value.trim().isEmpty ? 'Please describe your problem' : null,
                  ),
                  const SizedBox(height: 12),

                  // ====================================================================
                  // ATTACHMENT BOX PREVIEW UTILITY (Now linked to Device Gallery)
                  // ====================================================================
                  GestureDetector(
                    onTap: _pickScreenshotFromGallery, // Launches Image Picker Engine
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: cardBgColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: cardBorderColor),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _attachedFileName != null ? Icons.file_present_rounded : Icons.add_photo_alternate_outlined,
                            color: _attachedFileName != null ? const Color(0xFF10B981) : accentPrimaryColor,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _attachedFileName ?? 'Attach media evidence (Screenshot / Receipt)',
                              style: TextStyle(
                                fontSize: 13, 
                                color: _attachedFileName != null ? theme.colorScheme.onSurface : Colors.grey[500],
                                fontWeight: _attachedFileName != null ? FontWeight.bold : FontWeight.normal
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (_attachedFileName != null)
                            IconButton(
                              icon: Icon(Icons.cancel_rounded, size: 16, color: Colors.grey),
                              onPressed: () {
                                setState(() {
                                  _attachedFileName = null;
                                  _attachedFilePath = null;
                                });
                              },
                              padding: EdgeInsets.zero,
                              constraints: BoxConstraints(),
                            )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ====================================================================
                  // SUBMIT DISPATCH BUTTON MODULE
                  // ====================================================================
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentPrimaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      onPressed: _isSubmitting ? null : _submitTicket,
                      child: _isSubmitting
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Submit Problem Ticket', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}