import 'package:equatable/equatable.dart';

class NotificationEntity extends Equatable {
  final String id;
  final String title;
  final String message;
  final String type; // transaction, kyc, system, wallet
  final bool isRead;
  final Map<String, dynamic>? data;
  final DateTime createdAt;
  final bool isBroadcast; 

  const NotificationEntity({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    this.data,
    required this.createdAt,
    this.isBroadcast = false, // ✅ new
  });

  @override
  List<Object?> get props => [
    id,
    title,
    message,
    type,
    isRead,
    data,
    createdAt,
    isBroadcast,
  ];
}
