// lib/features/admin/presentation/bloc/admin_event.dart

abstract class AdminEvent {}

class LoadDashboardStats extends AdminEvent {}

class LoadAllUsers extends AdminEvent {
  final int limit;
  final int offset;
  LoadAllUsers({this.limit = 50, this.offset = 0});
}

class UpdateUserStatus extends AdminEvent {
  final String userId;
  final bool? isSuspended;
  final String? suspensionReason;
  UpdateUserStatus(this.userId, {this.isSuspended, this.suspensionReason});
}

class ApproveKycRequested extends AdminEvent {
  final String userId;
  ApproveKycRequested(this.userId);
}

class RejectKycRequested extends AdminEvent {
  final String userId;
  final String? reason;
  RejectKycRequested(this.userId, {this.reason});
}

class LoadTransactions extends AdminEvent {
  final String? type;
  final String? status;
  LoadTransactions({this.type, this.status});
}

class SendBroadcastNotificationEvent extends AdminEvent {
  final String title;
  final String body;
  SendBroadcastNotificationEvent(this.title, this.body);
}
