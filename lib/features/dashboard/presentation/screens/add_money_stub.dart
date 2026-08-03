import 'package:flutter/material.dart';

void handleWebPayment({
  required BuildContext context,
  required String publicKey,
  required String transactionId,
  required double amount,
  required String amountText,
  required String userIdentifier,
  required ValueChanged<bool> onProcessingChanged,
}) {}