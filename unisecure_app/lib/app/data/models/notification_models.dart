import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_icons.dart';

/// Notification category types across the university system.
enum NotificationType {
  attendance,
  security,
  academic,
  gate,
  system;

  String get label {
    switch (this) {
      case NotificationType.attendance:
        return 'Attendance';
      case NotificationType.security:
        return 'Campus Security';
      case NotificationType.academic:
        return 'Academic';
      case NotificationType.gate:
        return 'Perimeter Gate';
      case NotificationType.system:
        return 'Campus System';
    }
  }

  Color get color {
    switch (this) {
      case NotificationType.attendance:
        return AppColors.primary;
      case NotificationType.security:
        return AppColors.warning;
      case NotificationType.academic:
        return AppColors.teacherAccent;
      case NotificationType.gate:
        return AppColors.success;
      case NotificationType.system:
        return AppColors.info;
    }
  }

  IconData get icon {
    switch (this) {
      case NotificationType.attendance:
        return AppIcons.attendance;
      case NotificationType.security:
        return Icons.security_rounded;
      case NotificationType.academic:
        return AppIcons.courses;
      case NotificationType.gate:
        return Icons.meeting_room_outlined;
      case NotificationType.system:
        return Icons.info_outline_rounded;
    }
  }

  static NotificationType fromString(String type) {
    switch (type.toLowerCase()) {
      case 'attendance':
        return NotificationType.attendance;
      case 'security':
        return NotificationType.security;
      case 'academic':
        return NotificationType.academic;
      case 'gate':
        return NotificationType.gate;
      case 'system':
      default:
        return NotificationType.system;
    }
  }
}

/// Represents a campus notification or operational advisory.
class AppNotification {
  final String id;
  final String title;
  final String body;
  final String details;
  final NotificationType type;
  final String roleScope; // 'all', 'student', 'teacher', 'guard'
  final DateTime createdAt;
  final bool isRead;
  final String? actionLabel;
  final String? actionRoute;
  final String sender;

  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.details,
    required this.type,
    this.roleScope = 'all',
    required this.createdAt,
    this.isRead = false,
    this.actionLabel,
    this.actionRoute,
    this.sender = 'UniSecure Campus Authority',
  });

  AppNotification copyWith({
    String? id,
    String? title,
    String? body,
    String? details,
    NotificationType? type,
    String? roleScope,
    DateTime? createdAt,
    bool? isRead,
    String? actionLabel,
    String? actionRoute,
    String? sender,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      details: details ?? this.details,
      type: type ?? this.type,
      roleScope: roleScope ?? this.roleScope,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      actionLabel: actionLabel ?? this.actionLabel,
      actionRoute: actionRoute ?? this.actionRoute,
      sender: sender ?? this.sender,
    );
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    }
  }

  String get formattedDate {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final hour = createdAt.hour.toString().padLeft(2, '0');
    final minute = createdAt.minute.toString().padLeft(2, '0');
    return '${months[createdAt.month - 1]} ${createdAt.day}, ${createdAt.year} at $hour:$minute';
  }

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: '${json['id'] ?? ''}',
      title: '${json['title'] ?? ''}',
      body: '${json['body'] ?? json['message'] ?? ''}',
      details: '${json['details'] ?? json['body'] ?? ''}',
      type: NotificationType.fromString('${json['type'] ?? 'system'}'),
      roleScope: '${json['role_scope'] ?? 'all'}',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse('${json['created_at']}') ?? DateTime.now()
          : DateTime.now(),
      isRead: json['read_at'] != null || json['is_read'] == true,
      actionLabel: json['action_label'] as String?,
      actionRoute: json['action_route'] as String?,
      sender: '${json['sender'] ?? 'UniSecure Campus Authority'}',
    );
  }
}
