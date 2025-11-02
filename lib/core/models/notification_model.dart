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

