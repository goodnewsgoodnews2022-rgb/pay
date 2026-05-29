import 'package:equatable/equatable.dart';

class NotificationEntity extends Equatable {
  final String id;
  final String title;
  final String body;
  final String type; // transaction, kyc, system, wallet
  final bool isRead;
  final Map<String, dynamic>? data;
  final DateTime createdAt;

  const NotificationEntity({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.isRead,
    this.data,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    body,
    type,
    isRead,
    data,
    createdAt,
  ];
}
