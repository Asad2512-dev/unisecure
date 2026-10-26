import '../mock/notification_mock_data.dart';
import '../models/notification_models.dart';

/// Repository managing notification retrieval, read tracking, and state persistence.
class NotificationRepository {
  final bool simulateDelay;
  late List<AppNotification> _notifications;

  NotificationRepository({this.simulateDelay = true}) {
    _notifications = List.from(NotificationMockData.initialNotifications);
  }

  Future<void> _delay() async {
    if (simulateDelay) {
      await Future.delayed(const Duration(milliseconds: 250));
    }
  }

  /// Retrieves notifications scoped to the current user role or system-wide.
  Future<List<AppNotification>> getNotifications({
    String? role,
    String? filter, // 'all', 'unread'
    String? query,
  }) async {
    await _delay();
    var list = _notifications.where((n) {
      // Role scope filter
      if (role != null && role.isNotEmpty && role.toLowerCase() != 'admin') {
        final matchesRole =
            n.roleScope == 'all' ||
            n.roleScope.toLowerCase() == role.toLowerCase();
        if (!matchesRole) return false;
      }
      // Read state filter
      if (filter == 'unread' && n.isRead) return false;

      // Search query filter
      if (query != null && query.trim().isNotEmpty) {
        final q = query.trim().toLowerCase();
        final matchesQuery =
            n.title.toLowerCase().contains(q) ||
            n.body.toLowerCase().contains(q) ||
            n.type.label.toLowerCase().contains(q) ||
            n.sender.toLowerCase().contains(q);
        if (!matchesQuery) return false;
      }

      return true;
    }).toList();

    // Sort by latest first
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  /// Calculates total unread notifications count for role.
  Future<int> getUnreadCount({String? role}) async {
    final list = await getNotifications(role: role, filter: 'unread');
    return list.length;
  }

  /// Marks a specific notification as read.
  Future<bool> markAsRead(String id) async {
    await _delay();
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      return true;
    }
    return false;
  }

  /// Marks all scoped notifications as read.
  Future<int> markAllAsRead({String? role}) async {
    await _delay();
    int updatedCount = 0;
    for (int i = 0; i < _notifications.length; i++) {
      final n = _notifications[i];
      final matchesRole =
          role == null ||
          role.isEmpty ||
          role.toLowerCase() == 'admin' ||
          n.roleScope == 'all' ||
          n.roleScope.toLowerCase() == role.toLowerCase();

      if (matchesRole && !n.isRead) {
        _notifications[i] = n.copyWith(isRead: true);
        updatedCount++;
      }
    }
    return updatedCount;
  }

  /// Retrieves a single notification by its identifier.
  Future<AppNotification?> getNotificationById(String id) async {
    await _delay();
    try {
      return _notifications.firstWhere((n) => n.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Clears in-memory mutations and resets to default dataset.
  void reset() {
    _notifications = List.from(NotificationMockData.initialNotifications);
  }
}
