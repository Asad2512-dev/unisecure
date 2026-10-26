import 'package:get/get.dart';
import '../../../../core/auth/auth_controller.dart';
import '../../../data/models/notification_models.dart';
import '../../../data/repositories/notification_repository.dart';

/// GetX controller managing notifications state, filter chips, and read tracking.
class NotificationController extends GetxController {
  final NotificationRepository repo;

  NotificationController({NotificationRepository? repo})
    : repo = repo ?? NotificationRepository();

  final notifications = <AppNotification>[].obs;
  final isLoading = true.obs;
  final errorMessage = RxnString();
  final activeFilter = 'all'.obs; // 'all' | 'unread'
  final searchQuery = ''.obs;
  final unreadCount = 0.obs;

  String? get currentRole {
    if (Get.isRegistered<AuthController>()) {
      return Get.find<AuthController>().user.value?.role;
    }
    return null;
  }

  @override
  void onInit() {
    super.onInit();
    loadNotifications();
  }

  /// Loads notifications according to current filters and search query.
  Future<void> loadNotifications({bool showSkeleton = true}) async {
    if (showSkeleton) isLoading.value = true;
    errorMessage.value = null;

    try {
      final list = await repo.getNotifications(
        role: currentRole,
        filter: activeFilter.value,
        query: searchQuery.value,
      );
      notifications.assignAll(list);
      await refreshUnreadCount();
    } catch (e) {
      errorMessage.value =
          'Unable to load campus notifications. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  /// Updates unread count statistic badge.
  Future<void> refreshUnreadCount() async {
    final count = await repo.getUnreadCount(role: currentRole);
    unreadCount.value = count;
  }

  /// Toggles between 'all' and 'unread' filter states.
  Future<void> setFilter(String filter) async {
    if (activeFilter.value == filter) return;
    activeFilter.value = filter;
    await loadNotifications(showSkeleton: false);
  }

  /// Filters list by search keyword.
  Future<void> search(String query) async {
    searchQuery.value = query;
    await loadNotifications(showSkeleton: false);
  }

  /// Marks a specific notification as read and updates reactive state.
  Future<void> markAsRead(String id) async {
    final success = await repo.markAsRead(id);
    if (success) {
      final index = notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        notifications[index] = notifications[index].copyWith(isRead: true);
        if (activeFilter.value == 'unread') {
          notifications.removeAt(index);
        }
      }
      await refreshUnreadCount();
    }
  }

  /// Marks all visible/scoped notifications as read.
  Future<void> markAllAsRead() async {
    final updated = await repo.markAllAsRead(role: currentRole);
    if (updated > 0) {
      await loadNotifications(showSkeleton: false);
    }
  }
}
