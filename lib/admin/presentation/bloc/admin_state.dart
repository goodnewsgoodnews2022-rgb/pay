import 'package:fintech/admin/domain/entities/admin_dashboard_stat.dart';
import 'package:fintech/admin/domain/entities/admin_transaction.dart';
import 'package:fintech/admin/domain/entities/admin_user.dart';

abstract class AdminState {}

class AdminInitial extends AdminState {}

class AdminLoading extends AdminState {}

class AdminDashboardLoaded extends AdminState {
  final AdminDashboardStats stats;
  AdminDashboardLoaded(this.stats);
}

class AdminUsersLoaded extends AdminState {
  final List<AdminUser> users;
  final bool hasMore;
  AdminUsersLoaded(this.users, {this.hasMore = false});
}

class AdminTransactionsLoaded extends AdminState {
  final List<AdminTransaction> transactions;
  AdminTransactionsLoaded(this.transactions);
}

class AdminOperationSuccess extends AdminState {
  final String message;
  AdminOperationSuccess(this.message);
}

class AdminError extends AdminState {
  final String error;
  AdminError(this.error);
}
