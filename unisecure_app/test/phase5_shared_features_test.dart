import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:unisecure_app/app/core/theme/app_theme.dart';
import 'package:unisecure_app/app/data/models/notification_models.dart';
import 'package:unisecure_app/app/data/repositories/notification_repository.dart';
import 'package:unisecure_app/app/modules/guard/controllers/guard_controller.dart';
import 'package:unisecure_app/app/modules/guard/views/guard_shell_view.dart';
import 'package:unisecure_app/app/modules/notifications/controllers/notification_controller.dart';
import 'package:unisecure_app/app/modules/notifications/views/notification_detail_view.dart';
import 'package:unisecure_app/app/modules/notifications/views/notifications_view.dart';
import 'package:unisecure_app/app/modules/profile/views/shared_profile_view.dart';
import 'package:unisecure_app/app/modules/student/controllers/student_controller.dart';
import 'package:unisecure_app/app/modules/student/views/student_shell_view.dart';
import 'package:unisecure_app/app/modules/teacher/controllers/teacher_controller.dart';
import 'package:unisecure_app/app/modules/teacher/views/teacher_shell_view.dart';
import 'package:unisecure_app/core/api/api_client.dart';
import 'package:unisecure_app/core/auth/auth_controller.dart';
import 'package:unisecure_app/core/storage/secure_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Notification Models & Types Tests', () {
    test('NotificationType labels, colors, and icons map correctly', () {
      expect(NotificationType.attendance.label, 'Attendance');
      expect(NotificationType.security.label, 'Campus Security');
      expect(NotificationType.academic.label, 'Academic');
      expect(NotificationType.gate.label, 'Perimeter Gate');
      expect(NotificationType.system.label, 'Campus System');

      expect(
        NotificationType.fromString('attendance'),
        NotificationType.attendance,
      );
      expect(
        NotificationType.fromString('security'),
        NotificationType.security,
      );
      expect(
        NotificationType.fromString('academic'),
        NotificationType.academic,
      );
      expect(NotificationType.fromString('gate'), NotificationType.gate);
      expect(NotificationType.fromString('other'), NotificationType.system);
    });

    test('AppNotification calculates relative time and formatted date', () {
      final notif = AppNotification(
        id: 'test-1',
        title: 'Timetable Adjustment',
        body: 'Lecture shifted to Room 204',
        details: 'Lab is closed for routine maintenance.',
        type: NotificationType.academic,
        roleScope: 'student',
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
        isRead: false,
      );

      expect(notif.timeAgo, contains('5m ago'));
      expect(notif.formattedDate, isNotEmpty);
      expect(notif.isRead, isFalse);

      final updated = notif.copyWith(isRead: true);
      expect(updated.isRead, isTrue);
      expect(updated.id, 'test-1');
    });
  });

  group('NotificationRepository Tests', () {
    late NotificationRepository repo;

    setUp(() {
      repo = NotificationRepository(simulateDelay: false);
    });

    test('getNotifications returns non-empty list of campus alerts', () async {
      final list = await repo.getNotifications();
      expect(list, isNotEmpty);
      expect(list.any((n) => n.id == 'notif-101'), isTrue);
    });

    test('getNotifications scopes results by role correctly', () async {
      final studentList = await repo.getNotifications(role: 'student');
      final teacherList = await repo.getNotifications(role: 'teacher');
      final guardList = await repo.getNotifications(role: 'guard');

      // Student alerts should include student and all-scoped alerts
      for (final n in studentList) {
        expect(n.roleScope == 'student' || n.roleScope == 'all', isTrue);
      }
      for (final n in teacherList) {
        expect(n.roleScope == 'teacher' || n.roleScope == 'all', isTrue);
      }
      for (final n in guardList) {
        expect(n.roleScope == 'guard' || n.roleScope == 'all', isTrue);
      }
    });

    test('getNotifications filters unread and search query', () async {
      final unread = await repo.getNotifications(filter: 'unread');
      for (final n in unread) {
        expect(n.isRead, isFalse);
      }

      final searchResults = await repo.getNotifications(query: 'Perimeter');
      expect(searchResults, isNotEmpty);
      for (final n in searchResults) {
        final matches =
            n.title.toLowerCase().contains('perimeter') ||
            n.body.toLowerCase().contains('perimeter') ||
            n.type.label.toLowerCase().contains('perimeter');
        expect(matches, isTrue);
      }
    });

    test('markAsRead updates isRead property', () async {
      final initialUnreadCount = await repo.getUnreadCount();
      expect(initialUnreadCount, greaterThan(0));

      final success = await repo.markAsRead('notif-101');
      expect(success, isTrue);

      final n = await repo.getNotificationById('notif-101');
      expect(n?.isRead, isTrue);
    });

    test('markAllAsRead marks all notifications as read', () async {
      final updated = await repo.markAllAsRead();
      expect(updated, greaterThan(0));

      final unread = await repo.getUnreadCount();
      expect(unread, 0);
    });
  });

  group('NotificationController State Tests', () {
    late NotificationRepository repo;
    late NotificationController controller;

    setUp(() {
      Get.reset();
      Get.testMode = true;
      Get.put(ApiClient(secureStore: SecureStore()));
      Get.put(AuthController());
      repo = NotificationRepository(simulateDelay: false);
      controller = NotificationController(repo: repo);
      Get.put(controller);
    });

    tearDown(() {
      Get.reset();
      Get.testMode = true;
    });

    test(
      'Initializes with loaded notifications and calculated unread count',
      () async {
        await controller.loadNotifications(showSkeleton: false);
        expect(controller.notifications, isNotEmpty);
        expect(controller.unreadCount.value, greaterThan(0));
        expect(controller.isLoading.value, isFalse);
        expect(controller.errorMessage.value, isNull);
      },
    );

    test('setFilter updates active filter observable', () async {
      await controller.loadNotifications(showSkeleton: false);
      await controller.setFilter('unread');
      expect(controller.activeFilter.value, 'unread');
      for (final n in controller.notifications) {
        expect(n.isRead, isFalse);
      }
    });

    test('search updates search query and results', () async {
      await controller.loadNotifications(showSkeleton: false);
      controller.search('Maintenance');
      expect(controller.searchQuery.value, 'Maintenance');
    });

    test('markAsRead and markAllAsRead update reactive state', () async {
      await controller.loadNotifications(showSkeleton: false);
      await controller.markAllAsRead();
      expect(controller.unreadCount.value, 0);
    });
  });

  group('Shared UI Widget Tests', () {
    setUp(() {
      Get.reset();
      Get.testMode = true;
      Get.put(ApiClient(secureStore: SecureStore()));
      Get.put(AuthController());
      final notifRepo = NotificationRepository(simulateDelay: false);
      Get.put(NotificationController(repo: notifRepo));
    });

    tearDown(() {
      Get.reset();
      Get.testMode = true;
    });

    testWidgets('NotificationsView renders AppBar, search, chips and list', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(theme: AppTheme.light, home: const NotificationsView()),
      );
      await tester.pump();

      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('All Alerts'), findsOneWidget);
      expect(find.textContaining('Unread'), findsWidgets);
      expect(find.byType(TextField), findsOneWidget);
      expect(
        find.textContaining('Attendance Recorded: Advanced Algorithms'),
        findsOneWidget,
      );
    });

    testWidgets('NotificationDetailView renders complete instructions', (
      tester,
    ) async {
      final notif = AppNotification(
        id: 'detail-test',
        title: 'Emergency Drill Tomorrow',
        body: 'Mandatory fire evacuation drill at 10:00 AM.',
        details:
            'Please proceed calmly to the nearest designated assembly point outside Block B.',
        type: NotificationType.security,
        roleScope: 'all',
        createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
        isRead: false,
        actionLabel: 'View Assembly Map',
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: NotificationDetailView(notification: notif),
        ),
      );
      await tester.pump();

      expect(find.text('Notification Details'), findsOneWidget);
      expect(find.text('Emergency Drill Tomorrow'), findsOneWidget);
      expect(find.text('CAMPUS SECURITY'), findsOneWidget);
      expect(find.text('Official Advisory & Instructions'), findsOneWidget);
      expect(find.text('View Assembly Map'), findsOneWidget);
      expect(
        find.text('Back to Notifications', skipOffstage: false),
        findsOneWidget,
      );
    });

    testWidgets(
      'SharedProfileView adapts to student, teacher, and guard roles',
      (tester) async {
        // 1. Student Profile
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            home: const SharedProfileView(overrideRole: 'student'),
          ),
        );
        await tester.pump();

        expect(find.text('Student Profile'), findsOneWidget);
        expect(find.text('NUML UNIVERSITY'), findsOneWidget);
        expect(find.text('STUDENT'), findsOneWidget);
        expect(find.text('Academic Standing'), findsOneWidget);
        expect(find.text('ID: BSIT-MC-0001'), findsOneWidget);

        // 2. Teacher Profile
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            home: const SharedProfileView(overrideRole: 'teacher'),
          ),
        );
        await tester.pump();

        expect(find.text('Faculty Profile'), findsOneWidget);
        expect(find.text('FACULTY'), findsOneWidget);
        expect(find.text('Faculty Assignment'), findsOneWidget);
        expect(find.text('ID: FAC-CS-104'), findsOneWidget);

        // 3. Guard Profile
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            home: const SharedProfileView(overrideRole: 'guard'),
          ),
        );
        await tester.pump();

        expect(find.text('Security Officer Profile'), findsOneWidget);
        expect(find.text('SECURITY'), findsOneWidget);
        expect(find.text('Security Perimeter Assignment'), findsOneWidget);
        expect(find.text('ID: SEC-2022-004'), findsOneWidget);
        expect(find.text('Main Gate 1 (North Entrance)'), findsOneWidget);
      },
    );
  });

  group('Responsive Multi-Screen Size Validation Tests', () {
    final screenSizes = <String, Size>{
      '320x568 (Compact Mobile)': const Size(320, 568),
      '360x640 (Standard Android)': const Size(360, 640),
      '390x844 (Modern iPhone)': const Size(390, 844),
      '414x896 (Large Mobile)': const Size(414, 896),
      '768x1024 (Tablet Portrait)': const Size(768, 1024),
      '1024x768 (Tablet Landscape)': const Size(1024, 768),
    };

    setUp(() {
      Get.reset();
      Get.testMode = true;
      Get.put(ApiClient(secureStore: SecureStore()));
      final auth = Get.put(AuthController());
      auth.user.value = null;
      Get.put(StudentController());
      Get.put(TeacherController());
      Get.put(GuardController());
      Get.put(NotificationController());
    });

    tearDown(() {
      Get.reset();
      Get.testMode = true;
    });

    for (final entry in screenSizes.entries) {
      testWidgets(
        'Renders NotificationsView without overflow at ${entry.key}',
        (tester) async {
          tester.view.physicalSize = entry.value;
          tester.view.devicePixelRatio = 1.0;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);

          await tester.pumpWidget(
            MaterialApp(theme: AppTheme.light, home: const NotificationsView()),
          );
          await tester.pump();

          expect(tester.takeException(), isNull);
        },
      );

      testWidgets(
        'Renders SharedProfileView without overflow at ${entry.key}',
        (tester) async {
          tester.view.physicalSize = entry.value;
          tester.view.devicePixelRatio = 1.0;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);

          await tester.pumpWidget(
            MaterialApp(
              theme: AppTheme.light,
              home: const SharedProfileView(overrideRole: 'student'),
            ),
          );
          await tester.pump();

          expect(tester.takeException(), isNull);
        },
      );

      testWidgets('Renders StudentShellView without overflow at ${entry.key}', (
        tester,
      ) async {
        tester.view.physicalSize = entry.value;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          MaterialApp(theme: AppTheme.light, home: const StudentShellView()),
        );
        await tester.pump();

        expect(tester.takeException(), isNull);
      });

      testWidgets('Renders TeacherShellView without overflow at ${entry.key}', (
        tester,
      ) async {
        tester.view.physicalSize = entry.value;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          MaterialApp(theme: AppTheme.light, home: const TeacherShellView()),
        );
        await tester.pump();

        expect(tester.takeException(), isNull);
      });

      testWidgets('Renders GuardShellView without overflow at ${entry.key}', (
        tester,
      ) async {
        tester.view.physicalSize = entry.value;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          MaterialApp(theme: AppTheme.light, home: const GuardShellView()),
        );
        await tester.pump();

        expect(tester.takeException(), isNull);
      });
    }
  });
}
