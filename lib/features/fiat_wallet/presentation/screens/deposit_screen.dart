import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/fiat_wallet_bloc.dart';
import '../bloc/fiat_wallet_event.dart';
import '../widgets/amount_input_field.dart';

class DepositScreen extends StatefulWidget {
  final String walletId;
  const DepositScreen({required this.walletId, super.key});

  @override
  State<DepositScreen> createState() => _DepositScreenState();
}

class _DepositScreenState extends State<DepositScreen> {
  final _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCanvas,
      appBar: AppBar(
        backgroundColor: AppColors.bgSurface,
        title: const Text(
          'Deposit Funds',
          style: TextStyle(color: AppColors.textPrimary),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              AmountInputField(controller: _amountController),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final amount = double.parse(_amountController.text);
                    final reference =
                        'dep_${DateTime.now().millisecondsSinceEpoch}';
                    context.read<FiatWalletBloc>().add(
                      DepositRequested(widget.walletId, amount, reference),
                    );
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.dev2Green,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text(
                  'Confirm Deposit',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
