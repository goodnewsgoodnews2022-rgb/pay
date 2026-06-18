import 'package:fintech/features/KYC/domain/entities/kyc_status.dart';


class KycStatusModel extends KycStatus {
  const KycStatusModel({required super.status, super.reason});

  factory KycStatusModel.fromJson(Map<String, dynamic> json) {
    final statusStr = json['kyc_status'] as String? ?? 'pending';
    KycStatusEnum status;
    switch (statusStr) {
      case 'verified':
        status = KycStatusEnum.VERIFIED;
        break;
      case 'rejected':
        status = KycStatusEnum.REJECTED;
        break;
      case 'approved':
        status = KycStatusEnum.APPROVED;
        break;
      default:
        status = KycStatusEnum.PENDING;
    }
    return KycStatusModel(
      status: status,
      reason: json['kyc_rejection_reason'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'kyc_status': status.name, 'kyc_rejection_reason': reason};
  }
}
