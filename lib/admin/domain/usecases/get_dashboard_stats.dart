import 'package:fintech/admin/domain/entities/admin_dashboard_stat.dart';


import '../repositories/admin_repository.dart';

class GetDashboardStats {
  final AdminRepository repository;
  GetDashboardStats(this.repository);

  Future<AdminDashboardStats> call() => repository.getDashboardStats();
}
