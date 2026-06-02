class AppUser {
  final String id;
  final String email;
  final String? fullName;
  final String? mobileNumber;
  final String? gender;
  final String? dateOfBirth;
  final String? address;
  final String? avatarUrl;
  final String? accountNumber;
  final String? kycStatus;

  const AppUser({
    required this.id,
    required this.email,
    this.fullName,
    this.mobileNumber,
    this.gender,
    this.dateOfBirth,
    this.address,
    this.avatarUrl,
    this.accountNumber,
    this.kycStatus,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppUser &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
