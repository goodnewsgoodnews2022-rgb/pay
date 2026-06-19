// ignore_for_file: deprecated_member_use, unused_field, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ChangePinScreen extends StatefulWidget {
  const ChangePinScreen({super.key});

  @override
  State<ChangePinScreen> createState() => _ChangePinScreenState();
}

class _ChangePinScreenState extends State<ChangePinScreen> {
  String _pinCode = "";
  bool _isVerifyingOld = true;
  String _oldPinCaptured = "";
  bool _isProcessing = false;

  void _handleKeyPress(String value) {
    if (_pinCode.length >= 4) return;
    setState(() => _pinCode += value);
    if (_pinCode.length == 4) _evaluatePinStep();
  }

  void _handleBackspace() {
    if (_pinCode.isEmpty) return;
    setState(() => _pinCode = _pinCode.substring(0, _pinCode.length - 1));
  }

  void _evaluatePinStep() {
    setState(() => _isProcessing = true);

    Future.delayed(const Duration(milliseconds: 1000), () {
      if (!mounted) return;
      setState(() => _isProcessing = false);

      if (_isVerifyingOld) {
        if (_pinCode == "1234") {
          setState(() {
            _oldPinCaptured = _pinCode;
            _pinCode = "";
            _isVerifyingOld = false;
          });
        } else {
          setState(() => _pinCode = "");
          _triggerFailureToast("Invalid Current PIN entry. Try 1234");
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Transaction code rotated successfully.'), backgroundColor: const Color(0xFF10B981)),
        );
        context.pop();
      }
    });
  }

  void _triggerFailureToast(String logText) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(logText), backgroundColor: Colors.redAccent, behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Dynamic color structures
    final titleColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;
    final bottomPanelBg = isDark ? const Color(0xFF111622) : Colors.grey[100];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: titleColor), 
          onPressed: () => context.pop(),
        ),
        title: Text('Transaction Pin Asset', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: titleColor)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            Text(
              _isVerifyingOld ? 'Enter Current 4-Digit PIN' : 'Define New 4-Digit Transaction PIN',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: titleColor),
            ),
            const SizedBox(height: 8),
            Text(
              _isVerifyingOld ? 'Authorize balance edits using operational keys' : 'This numeric key authorizes outgoing wire transfers',
              style: TextStyle(fontSize: 11, color: subtitleColor),
            ),
            const SizedBox(height: 32),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                bool isActive = index < _pinCode.length;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isActive ? const Color(0xFF10B981) : subtitleColor.withOpacity(0.3),
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
            if (_isProcessing) SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 1.5, color: const Color(0xFF10B981))),
            
            const Spacer(),
            
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              color: bottomPanelBg,
              child: Column(
                children: [
                  _buildGridRow(['1', '2', '3'], titleColor),
                  _buildGridRow(['4', '5', '6'], titleColor),
                  _buildGridRow(['7', '8', '9'], titleColor),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(child: SizedBox.shrink()),
                      Expanded(child: _buildGridButton('0', titleColor)),
                      Expanded(
                        child: IconButton(
                          icon: Icon(Icons.backspace_outlined, size: 20, color: titleColor),
                          onPressed: _handleBackspace,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildGridRow(List<String> values, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: values.map((val) => Expanded(child: _buildGridButton(val, textColor))).toList(),
      ),
    );
  }

  Widget _buildGridButton(String displayVal, Color textColor) {
    return TextButton(
      onPressed: () => _handleKeyPress(displayVal),
      child: Text(
        displayVal,
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor),
      ),
    );
  }
}