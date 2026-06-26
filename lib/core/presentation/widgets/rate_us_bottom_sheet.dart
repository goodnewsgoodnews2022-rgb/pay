// ignore_for_file: prefer_const_constructors, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RateUsBottomSheet extends StatefulWidget {
  const RateUsBottomSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const RateUsBottomSheet(),
    );
  }

  @override
  State<RateUsBottomSheet> createState() => _RateUsBottomSheetState();
}

class _RateUsBottomSheetState extends State<RateUsBottomSheet> {
  final _supabase = Supabase.instance.client;
  final _feedbackController = TextEditingController();
  int _selectedRating = 0;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _submitRating() async {
    if (_selectedRating == 0) {
      _showSnackBar("Please select a star rating!", Colors.orangeAccent);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final user = _supabase.auth.currentUser;
      
      await _supabase.from('app_ratings').insert({
        'user_id': user?.id, // Can be null if anonymous, or tied to signed-in user id
        'rating': _selectedRating,
        'feedback': _feedbackController.text.trim().isEmpty 
            ? null 
            : _feedbackController.text.trim(),
      });

      _showSnackBar("Thank you for your rating!", const Color(0xFF10B981));
      Navigator.of(context).pop(); // Close Bottom Sheet
    } catch (e) {
      _showSnackBar("Failed to save rating. Try again.", Colors.redAccent);
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontWeight: FontWeight.w500)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    // Theme alignment matching your design system colors
    final bgBackground = isDarkMode ? const Color(0xFF090A0F) : const Color(0xFFF8FAFC);
    final cardBg = isDarkMode ? const Color(0xFF131520) : Colors.white;
    final textMain = isDarkMode ? Colors.white : const Color(0xFF0F172A);
    final textSecondary = isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF475569);
    final borderColors = isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: bgBackground,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle Bar Indicator
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: textSecondary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),

            Text(
              "Rate Our App",
              style: TextStyle(color: textMain, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "Your feedback helps us provide a better secure financial ecosystem experience.",
              textAlign: TextAlign.center,
              style: TextStyle(color: textSecondary, fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 24),

            // Interactive 5-Star Row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final starPosition = index + 1;
                final isSelected = starPosition <= _selectedRating;
                return IconButton(
                  onPressed: () => setState(() => _selectedRating = starPosition),
                  icon: Icon(
                    isSelected ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: isSelected ? const Color(0xFFFBBF24) : textSecondary.withOpacity(0.4),
                    size: 42,
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),

            // Optional Feedback Input Box
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: borderColors),
              ),
              child: TextField(
                controller: _feedbackController,
                maxLines: 3,
                style: TextStyle(color: textMain, fontSize: 14),
                decoration: InputDecoration(
                  hintText: "Tell us what we can improve (optional)...",
                  hintStyle: TextStyle(color: textSecondary.withOpacity(0.6), fontSize: 14),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Submission Button Node
            _isSubmitting
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF3B82F6)))
                : ElevatedButton(
                    onPressed: _submitRating,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B82F6), // Professional deep blue tint
                      minimumSize: const Size(double.infinity, 54),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: const Text(
                      "Submit Feedback",
                      style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}