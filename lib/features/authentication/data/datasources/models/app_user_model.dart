import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fintech/features/authentication/domain/entities/app_user.dart';
class AppUserModel extends AppUser {
  const AppUserModel({
    required super.id,
    required super.email,
    super.fullName,
    super.mobileNumber,
    super.gender,
    super.dateOfBirth,
    super.address,
    super.avatarUrl,
    super.accountNumber,
    super.kycStatus,
  });

  factory AppUserModel.fromJson(Map<String, dynamic> json) {
    return AppUserModel(
      id: json['id'],
      email: json['email'],
      fullName: json['full_name'],
      mobileNumber: json['mobile_number'],
      gender: json['gender'],
      dateOfBirth: json['date_of_birth'],
      address: json['address'],
      avatarUrl: json['avatar_url'],
      accountNumber: json['account_number'],
      kycStatus: json['kyc_status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'mobile_number': mobileNumber,
      'gender': gender,
      'date_of_birth': dateOfBirth,
      'address': address,
      'avatar_url': avatarUrl,
      'account_number': accountNumber,
      'kyc_status': kycStatus,
    };
  }

  factory AppUserModel.fromSupabaseUser(
    User user, {
    String? fullName,
    String? mobileNumber,
    String? gender,
    String? dateOfBirth,
    String? address,
    String? avatarUrl,
    String? accountNumber,
    String? kycStatus,
  }) {
    return AppUserModel(
      id: user.id,
      email: user.email!,
      fullName: fullName,
      mobileNumber: mobileNumber,
      gender: gender,
      dateOfBirth: dateOfBirth,
      address: address,
      avatarUrl: avatarUrl,
      accountNumber: accountNumber,
      kycStatus: kycStatus,
    );
  }
}
