// ignore_for_file: deprecated_member_use, prefer_const_declarations, prefer_const_constructors, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddBankCardAccountScreen extends ConsumerStatefulWidget {
  const AddBankCardAccountScreen({super.key});

  @override
  ConsumerState<AddBankCardAccountScreen> createState() => _AddBankCardAccountScreenState();
}

class _AddBankCardAccountScreenState extends ConsumerState<AddBankCardAccountScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _supabase = Supabase.instance.client;
  
  final _cardFormKey = GlobalKey<FormState>();
  final _bankFormKey = GlobalKey<FormState>();

  bool _isSaving = false;

  // --- Card Form Controllers ---
  final _cardNumberController = TextEditingController();
  final _cardExpiryController = TextEditingController();
  final _cardCvvController = TextEditingController();
  final _cardHolderController = TextEditingController();

  // --- Bank Form Controllers ---
  String? _selectedBankName;
  final _accountNumberController = TextEditingController();
  final _accountNameController = TextEditingController();

  // Comprehensive static list of popular Nigerian Banks for instant offline access
  final List<String> _nigerianBanks = [
    'Access Bank',
    'Citibank Nigeria',
    'Ecobank Nigeria',
    'Fidelity Bank',
    'First Bank of Nigeria',
    'First City Monument Bank (FCMB)',
    'Globus Bank',
    'Guaranty Trust Bank (GTBank)',
    'Heritage Bank',
    'Keystone Bank',
    'Kuda Bank',
    'Moniepoint MFB',
    'Opay',
    'Palmpay',
    'Parallex Bank',
    'PremiumTrust Bank',
    'Provadus Bank',
    'Stanbic IBTC Bank',
    'Standard Chartered Bank',
    'Sterling Bank',
    'SunTrust Bank',
    'Titan Trust Bank',
    'Union Bank of Nigeria',
    'United Bank for Africa (UBA)',
    'Unity Bank',
    'Wema Bank',
    'Zenith Bank',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _cardNumberController.dispose();
    _cardExpiryController.dispose();
    _cardCvvController.dispose();
    _cardHolderController.dispose();
    _accountNumberController.dispose();
    _accountNameController.dispose();
    super.dispose();
  }

  // --- Manual Card Saving Routine (Deposit Target) ---
  Future<void> _saveCardDetails() async {
    if (!_cardFormKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception("User session missing");

      final cleanCardNum = _cardNumberController.text.replaceAll(' ', '');
      final last4Digits = cleanCardNum.substring(cleanCardNum.length - 4);
      final expiryParts = _cardExpiryController.text.split('/');

      // Reset prior defaults for clean profile structure
      await _supabase.from('linked_cards').update({'is_default': false}).eq('user_id', user.id);

      // Save directly to Supabase
      await _supabase.from('linked_cards').insert({
        'user_id': user.id,
        'brand': _determineCardBrand(cleanCardNum),
        'last4': last4Digits,
        'exp_month': expiryParts[0].trim(),
        'exp_year': "20${expiryParts[1].trim()}",
        'card_holder': _cardHolderController.text.trim(),
        'is_default': true,
      });

      _showSnackBar("Card saved successfully for future deposits!", const Color(0xFF10B981));
      Navigator.of(context).pop();
    } catch (e) {
      _showSnackBar("Failed to save card entry: ${e.toString()}", Colors.redAccent);
    } finally {
      setState(() => _isSaving = false);
    }
  }

  // --- Manual Bank Account Saving Routine (Withdrawal/Deposit Target) ---
  Future<void> _saveBankAccountDetails() async {
    if (!_bankFormKey.currentState!.validate() || _selectedBankName == null) {
      _showSnackBar("Please select your bank institution", Colors.orangeAccent);
      return;
    }

    setState(() => _isSaving = true);
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception("User session missing");

      await _supabase.from('linked_banks').insert({
        'user_id': user.id,
        'bank_name': _selectedBankName,
        'account_number': _accountNumberController.text.trim(),
        'account_name': _accountNameController.text.trim(),
      });

      _showSnackBar("Bank Account saved successfully for payments!", const Color(0xFF10B981));
      Navigator.of(context).pop();
    } catch (e) {
      _showSnackBar("Failed to link your account details", Colors.redAccent);
    } finally {
      setState(() => _isSaving = false);
    }
  }

  String _determineCardBrand(String cardNumber) {
    if (cardNumber.startsWith('4')) return 'Visa';
    if (cardNumber.startsWith('5')) return 'Mastercard';
    if (cardNumber.startsWith('506') || cardNumber.startsWith('650')) return 'Verve';
    return 'Card';
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
    
    final scaffoldBg = isDarkMode ? const Color(0xFF090A0F) : const Color(0xFFF8FAFC);
    final mainTextColor = isDarkMode ? Colors.white : const Color(0xFF0F172A);
    final secondaryTextColor = isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF475569);
    final formFieldBg = isDarkMode ? const Color(0xFF131520) : Colors.white;
    final hintColor = isDarkMode ? Colors.grey[600] : Colors.grey[400];
    final inputBorderColor = isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);
    
    final brandPrimaryColor = const Color(0xFF3B82F6); 

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: scaffoldBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: mainTextColor, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Saved Payment Methods',
          style: TextStyle(color: mainTextColor, fontSize: 17, fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: brandPrimaryColor,
          unselectedLabelColor: secondaryTextColor,
          indicatorColor: brandPrimaryColor,
          indicatorSize: TabBarIndicatorSize.tab,
          indicatorWeight: 2.5,
          tabs: const [
            Tab(text: "Add Debit Card"),
            Tab(text: "Add Bank Account"),
          ],
        ),
      ),
      body: SafeArea(
        child: _isSaving
            ? Center(child: CircularProgressIndicator(color: brandPrimaryColor))
            : TabBarView(
                controller: _tabController,
                children: [
                  _buildCardForm(formFieldBg, inputBorderColor, mainTextColor, hintColor, brandPrimaryColor),
                  _buildBankForm(formFieldBg, inputBorderColor, mainTextColor, hintColor, brandPrimaryColor),
                ],
              ),
      ),
    );
  }

  // --- Add Card UI Tab Layout ---
  Widget _buildCardForm(Color fieldBg, Color borderColors, Color mainText, Color? hintColor, Color actionBtnColor) {
    return Form(
      key: _cardFormKey,
      child: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24.0),
        children: [
          Text("Cardholder Full Name", style: TextStyle(color: mainText, fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          _customTextField(
            controller: _cardHolderController,
            hint: "John Doe",
            fieldBg: fieldBg,
            borderColor: borderColors,
            mainTextColor: mainText,
            hintColor: hintColor,
            validator: (val) => val == null || val.trim().isEmpty ? "Enter full name listed on card" : null,
          ),
          const SizedBox(height: 20),

          Text("Card Number", style: TextStyle(color: mainText, fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          _customTextField(
            controller: _cardNumberController,
            hint: "4242 4242 4242 4242",
            keyboardType: TextInputType.number,
            fieldBg: fieldBg,
            borderColor: borderColors,
            mainTextColor: mainText,
            hintColor: hintColor,
            validator: (val) {
              if (val == null || val.replaceAll(' ', '').length < 16) return "Enter a valid 16-digit card number";
              return null;
            },
          ),
          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Expiry Date", style: TextStyle(color: mainText, fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    _customTextField(
                      controller: _cardExpiryController,
                      hint: "MM/YY",
                      keyboardType: TextInputType.number,
                      fieldBg: fieldBg,
                      borderColor: borderColors,
                      mainTextColor: mainText,
                      hintColor: hintColor,
                      validator: (val) {
                        if (val == null || !val.contains('/') || val.length < 5) return "Invalid date";
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("CVV Secure Code", style: TextStyle(color: mainText, fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    _customTextField(
                      controller: _cardCvvController,
                      hint: "123",
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      fieldBg: fieldBg,
                      borderColor: borderColors,
                      mainTextColor: mainText,
                      hintColor: hintColor,
                      validator: (val) => val == null || val.trim().length < 3 ? "Invalid CVV" : null,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 50),

          ElevatedButton(
            onPressed: _saveCardDetails,
            style: ElevatedButton.styleFrom(
              backgroundColor: actionBtnColor,
              minimumSize: const Size(double.infinity, 54),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: const Text("Save Secure Card Assets", style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // --- Add Bank Account UI Tab Layout ---
  Widget _buildBankForm(Color fieldBg, Color borderColors, Color mainText, Color? hintColor, Color actionBtnColor) {
    return Form(
      key: _bankFormKey,
      child: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24.0),
        children: [
          Text("Bank Institution", style: TextStyle(color: mainText, fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: fieldBg, 
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderColors)
            ),
            child: DropdownButtonFormField<String>(
              value: _selectedBankName,
              hint: Text("Choose Bank Profile", style: TextStyle(color: hintColor, fontSize: 14)),
              decoration: const InputDecoration(border: InputBorder.none),
              dropdownColor: fieldBg,
              style: TextStyle(color: mainText, fontSize: 14, fontWeight: FontWeight.w500),
              icon: Icon(Icons.keyboard_arrow_down_rounded, color: mainText.withOpacity(0.6)),
              items: _nigerianBanks.map((bankName) {
                return DropdownMenuItem<String>(
                  value: bankName,
                  child: Text(bankName),
                );
              }).toList(),
              onChanged: (val) => setState(() => _selectedBankName = val),
            ),
          ),
          const SizedBox(height: 20),

          Text("Account Number", style: TextStyle(color: mainText, fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          _customTextField(
            controller: _accountNumberController,
            hint: "Enter 10-digit account number",
            keyboardType: TextInputType.number,
            fieldBg: fieldBg,
            borderColor: borderColors,
            mainTextColor: mainText,
            hintColor: hintColor,
            validator: (val) => val == null || val.trim().length != 10 ? "Account number must be exactly 10 digits" : null,
          ),
          const SizedBox(height: 20),

          Text("Account Holder Name", style: TextStyle(color: mainText, fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          _customTextField(
            controller: _accountNameController,
            hint: "Enter matching beneficiary legal name",
            fieldBg: fieldBg,
            borderColor: borderColors,
            mainTextColor: mainText,
            hintColor: hintColor,
            validator: (val) => val == null || val.trim().isEmpty ? "Account name signature is required" : null,
          ),
          const SizedBox(height: 50),

          ElevatedButton(
            onPressed: _saveBankAccountDetails,
            style: ElevatedButton.styleFrom(
              backgroundColor: actionBtnColor,
              minimumSize: const Size(double.infinity, 54),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: const Text("Save Bank Details Node", style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // Common Reusable Premium Input Field Node
  Widget _customTextField({
    required TextEditingController controller,
    required String hint,
    required Color fieldBg,
    required Color borderColor,
    required Color mainTextColor,
    required Color? hintColor,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    required String? Function(String?)? validator,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: fieldBg, 
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        style: TextStyle(color: mainTextColor, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: hintColor, fontSize: 14),
          border: InputBorder.none,
        ),
        validator: validator,
      ),
    );
  }
}