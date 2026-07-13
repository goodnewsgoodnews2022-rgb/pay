// lib/features/admin/presentation/bloc/admin_bloc.dart

import 'package:fintech/admin/domain/usecases/get_all_user.dart';
import 'package:fintech/admin/domain/usecases/get_transaction.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fintech/admin/domain/usecases/get_dashboard_stats.dart';
import 'package:fintech/admin/domain/usecases/approve_kyc.dart';
import 'package:fintech/admin/domain/usecases/reject_kyc.dart';

import 'package:fintech/admin/domain/usecases/send_broadcast_notification.dart';
import 'admin_event.dart';
import 'admin_state.dart';

class AdminBloc extends Bloc<AdminEvent, AdminState> {
  final GetDashboardStats getDashboardStats;
  final GetAllUsers getAllUsers;
  final UpdateUserStatus updateUserStatus;
  final ApproveKyc approveKyc;
  final RejectKyc rejectKyc;
  final GetTransactions getTransactions;
  final SendBroadcastNotification sendBroadcastNotification;

  AdminBloc({
    required this.getDashboardStats,
    required this.getAllUsers,
    required this.updateUserStatus,
    required this.approveKyc,
    required this.rejectKyc,
    required this.getTransactions,
    required this.sendBroadcastNotification,
  }) : super(AdminInitial()) {
    on<LoadDashboardStats>(_onLoadDashboardStats);
    on<LoadAllUsers>(_onLoadAllUsers);
    on<UpdateUserStatus>(_onUpdateUserStatus);
    on<ApproveKycRequested>(_onApproveKyc);
    on<RejectKycRequested>(_onRejectKyc);
    on<LoadTransactions>(_onLoadTransactions);
    on<SendBroadcastNotificationEvent>(_onSendBroadcast);
  }

  Future<void> _onLoadDashboardStats(
    LoadDashboardStats event,
    Emitter<AdminState> emit,
  ) async {
    emit(AdminLoading());
    try {
      final stats = await getDashboardStats();
      emit(AdminDashboardLoaded(stats));
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> _onLoadAllUsers(
    LoadAllUsers event,
    Emitter<AdminState> emit,
  ) async {
    emit(AdminLoading());
    try {
      final users = await getAllUsers(
        limit: event.limit,
        offset: event.offset,
      );
      emit(AdminUsersLoaded(users, hasMore: users.length == event.limit));
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> _onUpdateUserStatus(
    UpdateUserStatus event,
    Emitter<AdminState> emit,
  ) async {
    try {
      await updateUserStatus;
      emit(AdminOperationSuccess('User status updated'));
      add(LoadAllUsers()); // Refresh list
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> _onApproveKyc(
    ApproveKycRequested event,
    Emitter<AdminState> emit,
  ) async {
    try {
      await approveKyc(event.userId);
      emit(AdminOperationSuccess('KYC approved successfully'));
      add(LoadAllUsers());
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> _onRejectKyc(
    RejectKycRequested event,
    Emitter<AdminState> emit,
  ) async {
    try {
      await rejectKyc(event.userId, reason: event.reason);
      emit(AdminOperationSuccess('KYC rejected'));
      add(LoadAllUsers());
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> _onLoadTransactions(
    LoadTransactions event,
    Emitter<AdminState> emit,
  ) async {
    emit(AdminLoading());
    try {
      final txs = await getTransactions(
        type: event.type,
        status: event.status,
      );
      emit(AdminTransactionsLoaded(txs));
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> _onSendBroadcast(
    SendBroadcastNotificationEvent event,
    Emitter<AdminState> emit,
  ) async {
    try {
      await sendBroadcastNotification(event.title, event.body);
      emit(AdminOperationSuccess('Broadcast sent successfully'));
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }
}
