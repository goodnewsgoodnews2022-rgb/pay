// ignore_for_file: constant_identifier_names

enum KycStatusEnum { PENDING, VERIFIED, REJECTED, APPROVED }

class KycStatus {
  final KycStatusEnum status;
  final String? reason;

  const KycStatus({required this.status, this.reason});

  bool get isVerified => status == KycStatusEnum.VERIFIED;
  bool get isPending => status == KycStatusEnum.PENDING;
  bool get isRejected => status == KycStatusEnum.REJECTED;
  bool get isApproved => status == KycStatusEnum.APPROVED;
}
