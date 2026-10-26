import 'package:flutter/material.dart';
import '../../app/modules/notifications/views/notifications_view.dart';

/// Legacy export wrapper forwarding to centralized Phase 5 NotificationsView.
class NotificationView extends StatelessWidget {
  const NotificationView({super.key});

  @override
  Widget build(BuildContext context) {
    return const NotificationsView();
  }
}
