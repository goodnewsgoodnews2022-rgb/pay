import 'package:fintech/features/authentication/domain/entities/app_user.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppUserModel extends AppUser {
  const AppUserModel({
    required super.id,
    required super.email,
    super.fullName,
    super.kycStatus,
  });

  factory AppUserModel.fromJson(Map<String, dynamic> json) {
    return AppUserModel(
      id: json['id'],
      email: json['email'],
      fullName: json['full_name'],
      kycStatus: json['kyc_status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'kyc_status': kycStatus,
    };
  }

  factory AppUserModel.fromSupabaseUser(
    User user, {
    String? fullName,
    String? kycStatus,
  }) {
    return AppUserModel(
      id: user.id,
      email: user.email!,
      fullName: fullName,
      kycStatus: kycStatus,
    );
  }
}
