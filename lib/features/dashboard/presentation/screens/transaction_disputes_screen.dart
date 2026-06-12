// ignore_for_file: deprecated_member_use, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DisputeModel {
  final String ticketId;
  final String transactionTarget;
  final String amount;
  final String status; // 'Submitted', 'Under Review', 'Resolved'
  final DateTime dateInitiated;

  DisputeModel({
    required this.ticketId,
    required this.transactionTarget,
    required this.amount,
    required this.status,
    required this.dateInitiated,
  });
}

class TransactionDisputesScreen extends StatefulWidget {
  const TransactionDisputesScreen({super.key});

  @override
  State<TransactionDisputesScreen> createState() => _TransactionDisputesScreenState();
}

class _TransactionDisputesScreenState extends State<TransactionDisputesScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _explanationController = TextEditingController();
  
  String? _selectedTransaction;
  String? _attachedEvidenceName;
  bool _isSubmitting = false;

  // Mock Active Ongoing Dispute for the Tracker component
  final DisputeModel _activeDispute = DisputeModel(
    ticketId: "DISP-88301",
    transactionTarget: "POS Purchase • Amazon Vendor PMTS",
    amount: "-\$142.50",
    status: "Under Review", // Switch between 'Submitted', 'Under Review', 'Resolved'
    dateInitiated: DateTime.now().subtract(const Duration(days: 2)),
  );

  // Example recent transactions available for dispute selection
  final List<Map<String, String>> _recentTransactions = [
    {'id': 'TXN-4921', 'title': 'Netflix Subscription Premium', 'amount': '-\$22.99'},
    {'id': 'TXN-9023', 'title': 'Uber Trip Ledger Ride', 'amount': '-\$34.20'},
    {'id': 'TXN-1104', 'title': 'Stripe *DigitalProduct Service', 'amount': '-\$85.00'},
  ];

  void _pickTransactionSheet() {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.brightness == Brightness.dark ? const Color(0xFF151424) : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Select Transaction to Dispute', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ),
              Divider(height: 1),
              ..._recentTransactions.map((txn) => ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.redAccent.withOpacity(0.1),
                  child: Icon(Icons.payment_rounded, color: Colors.redAccent, size: 18),
                ),
                title: Text(txn['title']!, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                subtitle: Text(txn['id']!, style: TextStyle(fontSize: 11)),
                trailing: Text(txn['amount']!, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent)),
                onTap: () {
                  setState(() {
                    _selectedTransaction = "${txn['title']} (${txn['amount']})";
                  });
                  Navigator.pop(context);
                },
              )),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _submitDisputeForm() {
    if (!_formKey.currentState!.validate() || _selectedTransaction == null) {
      if (_selectedTransaction == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select a transaction first'), backgroundColor: Colors.orangeAccent)
        );
      }
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
      });
      _showConfirmationAlert();
    });
  }

  void _showConfirmationAlert() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF151424) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.shield_outlined, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            Text('Dispute Logged', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text('Charge hold request sent. Our operations desk has frozen transaction settlements with the vendor while evaluating your filing details.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.pop();
            },
            child: Text('Understood', style: TextStyle(fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardBgColor = isDark ? const Color(0xFF151424) : Colors.grey[50];
    final cardBorderColor = isDark ? const Color(0xFF26243C) : Colors.grey[200]!;
    final accentColor = theme.colorScheme.primary != theme.scaffoldBackgroundColor ? theme.colorScheme.primary : const Color(0xFF8B5CF6);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20), onPressed: () => context.pop()),
        title: Text('Transaction Disputes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ====================================================================
              // REQUIREMENT: TRACK DISPUTE STATUS (Visual Pipeline Step Indicator)
              // ====================================================================
              Text('Active Claim Tracking', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface.withOpacity(0.6))),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: cardBgColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: cardBorderColor)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_activeDispute.ticketId, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: accentColor)),
                        Text(_activeDispute.amount, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.redAccent)),
                      ],
                    ),
                    Text(_activeDispute.transactionTarget, style: TextStyle(fontSize: 12, color: Colors.grey, height: 1.4)),
                    const SizedBox(height: 20),
                    _buildTrackingStepper(currentStatus: _activeDispute.status, activeColor: accentColor),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              Text('File a New Charge Dispute', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface.withOpacity(0.6))),
              const SizedBox(height: 12),

              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ====================================================================
                    // REQUIREMENT: SELECT A TRANSACTION
                    // ====================================================================
                    InkWell(
                      onTap: _pickTransactionSheet,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(color: isDark ? const Color(0xFF0A0A10) : Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: cardBorderColor)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                _selectedTransaction ?? 'Tap to select disputed transaction charge...',
                                style: TextStyle(fontSize: 13, color: _selectedTransaction != null ? theme.colorScheme.onSurface : Colors.grey, fontWeight: _selectedTransaction != null ? FontWeight.bold : FontWeight.normal),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Icon(Icons.unfold_more_rounded, size: 18, color: accentColor),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ====================================================================
                    // REQUIREMENT: EXPLAIN THE ISSUE
                    // ====================================================================
                    TextFormField(
                      controller: _explanationController,
                      maxLines: 4,
                      style: TextStyle(fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'Explain the issue context (e.g. dynamic double charge, vendor never shipped item, unexpected transaction conversion fee manipulation)...',
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 13, height: 1.4),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF0A0A10) : Colors.white,
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: cardBorderColor)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: accentColor, width: 1.5)),
                        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.redAccent)),
                      ),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Explanation required to file arbitration claim' : null,
                    ),
                    const SizedBox(height: 16),

                    // ====================================================================
                    // REQUIREMENT: UPLOAD EVIDENCE
                    // ====================================================================
                    GestureDetector(
                      onTap: () => setState(() => _attachedEvidenceName = "invoice_receipt_proof.jpg"),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: cardBgColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: cardBorderColor, style: BorderStyle.solid)),
                        child: Row(
                          children: [
                            Icon(_attachedEvidenceName != null ? Icons.assignment_turned_in_rounded : Icons.cloud_upload_outlined, color: _attachedEvidenceName != null ? const Color(0xFF10B981) : accentColor, size: 20),
                            const SizedBox(width: 12),
                            Expanded(child: Text(_attachedEvidenceName ?? 'Upload Supporting Evidence (Receipt / Invoice Core)', style: TextStyle(fontSize: 12, color: Colors.grey))),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: accentColor, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
                        onPressed: _isSubmitting ? null : _submitDisputeForm,
                        child: _isSubmitting ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Launch Arbitration Dispute', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrackingStepper({required String currentStatus, required Color activeColor}) {
    final steps = ['Submitted', 'Under Review', 'Resolved'];
    int currentIndex = steps.indexOf(currentStatus);
    if (currentIndex == -1) currentIndex = 0;

    return Row(
      children: List.generate(steps.length, (index) {
        final isCompleted = index <= currentIndex;
        final isLast = index == steps.length - 1;

        return Expanded(
          flex: isLast ? 0 : 1,
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 10,
                    backgroundColor: isCompleted ? activeColor : Colors.grey.withOpacity(0.2),
                    child: Icon(Icons.check, size: 10, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(steps[index], style: TextStyle(fontSize: 10, fontWeight: isCompleted ? FontWeight.bold : FontWeight.normal, color: isCompleted ? activeColor : Colors.grey)),
                ],
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    height: 2,
                    margin: const EdgeInsets.only(bottom: 14, left: 4, right: 4),
                    color: index < currentIndex ? activeColor : Colors.grey.withOpacity(0.3),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}