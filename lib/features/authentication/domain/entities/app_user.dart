class AppUser {
  final String id;
  final String email;
  final String? fullName;
  final String? kycStatus;

  const AppUser({
    required this.id,
    required this.email,
    this.fullName,
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
