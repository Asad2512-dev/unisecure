import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unisecure_app/app/core/theme/app_theme.dart';
import 'package:unisecure_app/app/data/models/student_models.dart';
import 'package:unisecure_app/app/data/repositories/student_repository.dart';
import 'package:unisecure_app/app/modules/student/controllers/student_controller.dart';
import 'package:unisecure_app/app/modules/student/views/courses/course_detail_view.dart';
import 'package:unisecure_app/app/modules/student/views/courses/student_courses_view.dart';
import 'package:unisecure_app/app/modules/student/views/profile/student_profile_view.dart';
import 'package:unisecure_app/app/modules/student/views/security/student_campus_history_view.dart';
import 'package:unisecure_app/app/modules/student/views/student_shell_view.dart';
import 'package:unisecure_app/app/modules/student/views/tabs/student_attendance_tab.dart';
import 'package:unisecure_app/app/modules/student/views/tabs/student_home_tab.dart';
import 'package:unisecure_app/app/modules/student/views/tabs/student_more_tab.dart';
import 'package:unisecure_app/app/modules/student/views/tabs/student_timetable_tab.dart';
import 'package:unisecure_app/core/api/api_client.dart';
import 'package:unisecure_app/core/auth/auth_controller.dart';
import 'package:unisecure_app/core/storage/secure_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
  Get.testMode = true;

  group('StudentRepository & Models Tests', () {
    final repo = StudentRepository(simulateDelay: false);

    test('getProfile returns valid StudentProfile', () async {
      final profile = await repo.getProfile();
      expect(profile.name, 'Faizan Khan');
      expect(profile.studentIdNumber, 'BSIT-MC-0001');
      expect(profile.semester, 4);
      expect(profile.cgpa, 3.82);
    });

    test(
      'getCourses returns enrolled courses with valid attendance percentages',
      () async {
        final courses = await repo.getCourses();
        expect(courses.length, 5);
        expect(courses.first.code, 'CS-301');
        expect(courses.first.attendancePercentage, greaterThanOrEqualTo(90.0));
      },
    );

    test('getCourses with query filters matching courses', () async {
      final results = await repo.getCourses(query: 'distributed');
      expect(results.length, 1);
      expect(results.first.code, 'CS-301');
    });

    test('getTimetable returns slot records for weekdays', () async {
      final slots = await repo.getTimetable(dayOfWeek: 1);
      expect(slots.isNotEmpty, isTrue);
      expect(slots.first.dayOfWeek, 1);
    });

    test('getAttendance filters by status correctly', () async {
      final absent = await repo.getAttendance(statusFilter: 'absent');
      expect(absent.every((a) => a.status == 'absent'), isTrue);
    });

    test('getAccessTransactions returns campus entry/exit events', () async {
      final entries = await repo.getAccessTransactions(filter: 'entry');
      expect(entries.every((tx) => tx.eventType == 'entry'), isTrue);
    });
  });

  group('StudentController State Tests', () {
    late StudentController controller;

    setUp(() async {
      Get.reset();
      Get.testMode = true;
      controller = StudentController(
        repo: StudentRepository(simulateDelay: false),
      );
      Get.put(controller);
      await controller.loadAll(showSpinner: false);
    });

    tearDown(() {
      Get.reset();
      Get.testMode = true;
    });

    test('Initial state loads profile and course records', () {
      expect(controller.profile.value?.name, 'Faizan Khan');
      expect(controller.courses.length, 5);
      expect(controller.timetable.isNotEmpty, isTrue);
      expect(controller.attendanceRecords.isNotEmpty, isTrue);
      expect(controller.accessHistory.isNotEmpty, isTrue);
    });

    test('Tab switching updates currentTabIndex', () {
      expect(controller.currentTabIndex.value, 0);
      controller.changeTab(2);
      expect(controller.currentTabIndex.value, 2);
    });

    test('Day selection updates selectedDayOfWeek and filtered slots', () {
      controller.selectDay(2);
      expect(controller.selectedDayOfWeek.value, 2);
      expect(
        controller.slotsForSelectedDay.every((s) => s.dayOfWeek == 2),
        isTrue,
      );
    });

    test('Attendance filter filters records accordingly', () {
      controller.filterAttendance('Late');
      expect(controller.selectedAttendanceFilter.value, 'Late');
      expect(
        controller.filteredAttendanceRecords.every(
          (r) => r.status.toLowerCase() == 'late',
        ),
        isTrue,
      );
    });

    test('Course search filters courses list', () {
      controller.searchCourses('networks');
      expect(controller.filteredCourses.length, 1);
      expect(controller.filteredCourses.first.code, 'CS-308');
    });

    test('Overall attendance rate is calculated correctly', () {
      final rate = controller.overallAttendanceRate;
      expect(rate, greaterThan(85.0));
      expect(rate, lessThanOrEqualTo(100.0));
    });
  });

  group('Student UI Widget Tests', () {
    setUp(() async {
      Get.reset();
      Get.testMode = true;
      Get.put(ApiClient(secureStore: SecureStore()));
      Get.put(AuthController());
      final studentCtrl = StudentController(
        repo: StudentRepository(simulateDelay: false),
      );
      Get.put(studentCtrl);
      await studentCtrl.loadAll(showSpinner: false);
    });

    tearDown(() {
      Get.reset();
      Get.testMode = true;
    });

    testWidgets('StudentHomeTab renders greeting, next class, and attendance', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(body: StudentHomeTab()),
        ),
      );
      await tester.pump();

      expect(find.textContaining('Faizan'), findsOneWidget);
      expect(find.text('Overall Attendance'), findsOneWidget);
      expect(find.text('Quick Actions'), findsOneWidget);
      expect(find.text('Timetable'), findsOneWidget);
      expect(find.text('Attendance'), findsOneWidget);
      expect(find.text('Courses'), findsOneWidget);
    });

    testWidgets('StudentTimetableTab displays day selector and class slots', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(body: StudentTimetableTab()),
        ),
      );
      await tester.pump();

      expect(find.text('Mon'), findsOneWidget);
      expect(find.text('Tue'), findsOneWidget);
      expect(find.text('Wed'), findsOneWidget);
    });

    testWidgets('StudentAttendanceTab renders summary and session history', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(body: StudentAttendanceTab()),
        ),
      );
      await tester.pump();

      expect(find.text('Course Summary'), findsOneWidget);
      expect(find.text('Session History'), findsOneWidget);
      expect(find.text('Semester Attendance'), findsOneWidget);
      expect(find.text('Course-wise Attendance'), findsOneWidget);
    });

    testWidgets('StudentMoreTab renders academic and security menu options', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(body: StudentMoreTab()),
        ),
      );
      await tester.pump();

      expect(find.text('My Enrolled Courses'), findsOneWidget);
      expect(find.text('Campus Access Log'), findsOneWidget);
      expect(find.text('Sign Out', skipOffstage: false), findsOneWidget);
    });

    testWidgets('StudentCoursesView lists courses and filters on search', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(theme: AppTheme.light, home: const StudentCoursesView()),
      );
      await tester.pump();

      expect(find.text('My Courses'), findsOneWidget);
      expect(find.text('CS-301'), findsOneWidget);
      expect(find.text('CS-305'), findsOneWidget);
    });

    testWidgets('CourseDetailView renders course academic details', (
      tester,
    ) async {
      const sampleCourse = StudentCourse(
        id: 'c-test',
        code: 'CS-301',
        title: 'Distributed Systems',
        description: 'Testing course syllabus description.',
        instructorName: 'Dr. Evelyn Reed',
        instructorEmail: 'e.reed@faculty.unisecure.edu',
        section: 'Sec A',
        credits: 4,
        room: 'LH-102',
        schedule: 'Mon, Wed 09:00 - 10:30',
        totalClasses: 16,
        attendedClasses: 15,
        lateClasses: 1,
        absentClasses: 0,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const CourseDetailView(course: sampleCourse),
        ),
      );
      await tester.pump();

      expect(find.text('CS-301'), findsNWidgets(2));
      expect(find.text('Distributed Systems'), findsOneWidget);
      expect(find.text('Dr. Evelyn Reed'), findsOneWidget);
      expect(
        find.text('Testing course syllabus description.', skipOffstage: false),
        findsOneWidget,
      );
    });

    testWidgets('StudentCampusHistoryView renders gate transactions', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const StudentCampusHistoryView(),
        ),
      );
      await tester.pump();

      expect(find.text('Campus Access Log'), findsOneWidget);
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Entry'), findsOneWidget);
      expect(find.text('Exit'), findsOneWidget);
      expect(find.textContaining('Gate 1'), findsWidgets);
    });

    testWidgets('StudentProfileView renders digital student identity card', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(theme: AppTheme.light, home: const StudentProfileView()),
      );
      await tester.pump();

      expect(find.text('Student Identity Card'), findsOneWidget);
      expect(find.text('NUML UNIVERSITY'), findsOneWidget);
      expect(find.text('STUDENT'), findsOneWidget);
      expect(find.text('Faizan Khan'), findsOneWidget);
      expect(find.text('ID: BSIT-MC-0001'), findsOneWidget);
    });

    testWidgets(
      'StudentShellView initializes with bottom nav and loads Home tab',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(theme: AppTheme.light, home: const StudentShellView()),
        );
        await tester.pump();

        expect(find.text('Uni Secure'), findsOneWidget);
        expect(find.text('STUDENT'), findsOneWidget);
        expect(find.text('Home'), findsOneWidget);
        expect(find.text('Timetable'), findsOneWidget);
        expect(find.text('Attendance'), findsOneWidget);
        expect(find.text('More'), findsOneWidget);
      },
    );
  });
}
