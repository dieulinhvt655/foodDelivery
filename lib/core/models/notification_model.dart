import 'package:flutter/material.dart';

class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String? message;
  final DateTime createdAt;
  final bool isRead;
  final IconData icon;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    this.message,
    required this.createdAt,
    this.isRead = false,
    required this.icon,
  });

  /// JSON từ backend notification-service
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final metadata = json['metadata'] as Map<String, dynamic>?;
    final eventType = metadata?['eventType'] as String?;

    IconData pickIcon() {
      if (eventType == null) return Icons.notifications_none_rounded;
      if (eventType.startsWith('order.')) return Icons.receipt_long_outlined;
      if (eventType == 'payment.success') return Icons.check_circle_outline;
      if (eventType == 'promotion.new') return Icons.local_offer_outlined;
      if (eventType == 'user.registered') return Icons.person_add_alt_1_outlined;
      return Icons.notifications_none_rounded;
    }

    final created =
        (json['created_at'] ?? json['createdAt'] ?? DateTime.now().toIso8601String()) as String;

    return NotificationModel(
      id: json['id'].toString(),
      userId: (json['userId'] ?? json['user_id'] ?? '').toString(),
      title: json['title'] ?? '',
      message: json['content'] as String?,
      createdAt: DateTime.parse(created),
      isRead: json['isRead'] == true || json['is_read'] == true,
      icon: pickIcon(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'message': message,
      'created_at': createdAt.toIso8601String(),
      'is_read': isRead ? 1 : 0,
      'icon_code_point': icon.codePoint,
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      title: map['title'] as String,
      message: map['message'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      isRead: (map['is_read'] as int) == 1,
      icon: IconData(map['icon_code_point'] as int, fontFamily: 'MaterialIcons'),
    );
  }
}

