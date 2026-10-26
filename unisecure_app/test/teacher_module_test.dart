import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unisecure_app/app/core/theme/app_theme.dart';
import 'package:unisecure_app/app/core/widgets/widgets.dart';
import 'package:unisecure_app/app/data/models/teacher_models.dart';
import 'package:unisecure_app/app/data/repositories/teacher_repository.dart';
import 'package:unisecure_app/app/modules/teacher/controllers/teacher_controller.dart';
import 'package:unisecure_app/app/modules/teacher/controllers/teacher_roster_controller.dart';
import 'package:unisecure_app/app/modules/teacher/views/courses/teacher_course_detail_view.dart';
import 'package:unisecure_app/app/modules/teacher/views/roster/teacher_roster_view.dart';
import 'package:unisecure_app/app/modules/teacher/views/teacher_shell_view.dart';
import 'package:unisecure_app/app/modules/teacher/views/tabs/teacher_courses_tab.dart';
import 'package:unisecure_app/app/modules/teacher/views/tabs/teacher_home_tab.dart';
import 'package:unisecure_app/app/modules/teacher/views/tabs/teacher_sessions_tab.dart';
import 'package:unisecure_app/app/modules/teacher/views/tabs/teacher_timetable_tab.dart';
import 'package:unisecure_app/core/api/api_client.dart';
import 'package:unisecure_app/core/auth/auth_controller.dart';
import 'package:unisecure_app/core/storage/secure_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
  Get.testMode = true;

  group('TeacherRepository & Models Tests', () {
    final repo = TeacherRepository(simulateDelay: false);

    test('getProfile returns valid TeacherProfile', () async {
      final profile = await repo.getProfile();
      expect(profile.name, 'Dr. Evelyn Reed');
      expect(profile.teacherIdNumber, 'FAC-2018-0914');
      expect(
        profile.department,
        'Department of Computing & Information Security',
      );
      expect(profile.designation, 'Associate Professor & Systems Lead');
      expect(profile.officeRoom, 'Faculty Block B • Room 314');
    });

    test('getCourses returns assigned faculty courses', () async {
      final courses = await repo.getCourses();
      expect(courses.length, 3);
      expect(courses.first.code, 'CS-301');
      expect(courses.first.title, 'Distributed Systems & Cloud Computing');
      expect(courses.first.enrolledStudentCount, 38);
    });

    test('getCourses with query filters matching courses', () async {
      final results = await repo.getCourses(query: 'virtualization');
      expect(results.length, 1);
      expect(results.first.code, 'CS-302');
    });

    test('getSessions returns sessions and filters by status', () async {
      final all = await repo.getSessions();
      expect(all.length, 6);

      final openSessions = await repo.getSessions(statusFilter: 'open');
      expect(openSessions.every((s) => s.isOpen), isTrue);

      final finalizedSessions = await repo.getSessions(
        statusFilter: 'finalized',
      );
      expect(finalizedSessions.every((s) => s.isFinalized), isTrue);
    });

    test('getTimetable returns slots for given weekday', () async {
      final slots = await repo.getTimetable(dayOfWeek: 1);
      expect(slots.isNotEmpty, isTrue);
      expect(slots.every((s) => s.dayOfWeek == 1), isTrue);
      expect(slots.first.courseCode, 'CS-301');
    });

    test('getSessionRoster returns student list with initial states', () async {
      final roster = await repo.getSessionRoster('sess-today-open');
      expect(roster.length, 12);
      expect(roster.first.name, 'Faizan Khan');
      expect(roster.first.studentIdNumber, 'BSIT-MC-0001');
    });

    test('saveRosterDraft updates student attendance status locally', () async {
      final roster = await repo.getSessionRoster('sess-today-open');
      final updatedRoster = roster.map((s) {
        if (s.id == 'st-1') {
          return s.copyWith(attendanceStatus: 'present');
        }
        return s;
      }).toList();

      await repo.saveRosterDraft('sess-today-open', updatedRoster);
      final fetched = await repo.getSessionRoster('sess-today-open');
      expect(
        fetched.firstWhere((s) => s.id == 'st-1').attendanceStatus,
        'present',
      );
    });

    test(
      'finalizeSession marks session finalized and converts unmarked to absent',
      () async {
        final initialRoster = await repo.getSessionRoster('sess-today-open');
        final updatedSession = await repo.finalizeSession(
          'sess-today-open',
          initialRoster,
        );

        expect(updatedSession.isFinalized, isTrue);
        expect(updatedSession.status, 'finalized');

        final finalizedRoster = await repo.getSessionRoster('sess-today-open');
        // Any student who was unmarked is now converted to absent
        expect(finalizedRoster.every((s) => !s.isUnmarked), isTrue);
      },
    );
  });

  group('TeacherController State Tests', () {
    late TeacherController controller;

    setUp(() async {
      Get.reset();
      Get.testMode = true;
      controller = TeacherController(
        repo: TeacherRepository(simulateDelay: false),
      );
      Get.put(controller);
      await controller.loadAll(showSpinner: false);
    });

    tearDown(() {
      Get.reset();
      Get.testMode = true;
    });

    test('Initial state loads faculty profile, courses, and sessions', () {
      expect(controller.profile.value?.name, 'Dr. Evelyn Reed');
      expect(controller.courses.length, 3);
      expect(controller.sessions.length, 6);
      expect(controller.timetable.isNotEmpty, isTrue);
    });

    test('Computed sessions reflect active and upcoming classes', () {
      expect(controller.activeSessionToMark, isNotNull);
      expect(controller.activeSessionToMark?.isOpen, isTrue);
      expect(controller.nextScheduledClass, isNotNull);
      expect(controller.nextScheduledClass?.isUpcoming, isTrue);
      expect(controller.recentlyCompletedSessions.isNotEmpty, isTrue);
    });

    test('Tab switching updates currentTabIndex', () {
      expect(controller.currentTabIndex.value, 0);
      controller.changeTab(1);
      expect(controller.currentTabIndex.value, 1);
      controller.changeTab(3);
      expect(controller.currentTabIndex.value, 3);
    });

    test(
      'Day selection updates selectedDayOfWeek and filtered timetable slots',
      () {
        controller.selectDay(3);
        expect(controller.selectedDayOfWeek.value, 3);
        expect(
          controller.slotsForSelectedDay.every((s) => s.dayOfWeek == 3),
          isTrue,
        );
      },
    );

    test('Session filtering by category works as expected', () {
      controller.filterSessions('Open');
      expect(controller.filteredSessions.every((s) => s.isOpen), isTrue);

      controller.filterSessions('Finalized');
      expect(controller.filteredSessions.every((s) => s.isFinalized), isTrue);

      controller.filterSessions('All');
      expect(controller.filteredSessions.length, 6);
    });

    test('Course search filters assigned courses list', () {
      controller.searchCourses('distributed');
      expect(controller.filteredCourses.length, 1);
      expect(controller.filteredCourses.first.code, 'CS-301');
    });
  });

  group('TeacherRosterController Roster & Finalization Tests', () {
    late TeacherRepository repo;
    late TeacherSession testSession;
    late TeacherRosterController rosterCtrl;

    setUp(() async {
      Get.reset();
      Get.testMode = true;
      repo = TeacherRepository(simulateDelay: false);
      final sessions = await repo.getSessions();
      testSession = sessions.firstWhere((s) => s.id == 'sess-today-open');

      rosterCtrl = TeacherRosterController(
        initialSession: testSession,
        repo: repo,
      );
      Get.put(rosterCtrl);
      await rosterCtrl.loadRoster();
    });

    tearDown(() {
      Get.reset();
      Get.testMode = true;
    });

    test('Initial roster loads 12 students with initial states', () {
      expect(rosterCtrl.roster.length, 12);
      expect(rosterCtrl.hasUnsavedChanges.value, isFalse);
      expect(rosterCtrl.session.value.isFinalized, isFalse);
    });

    test('Marking single student updates state and marks unsaved changes', () {
      final studentId = rosterCtrl.roster.first.id;
      rosterCtrl.updateStudentStatus(studentId, 'present');

      expect(rosterCtrl.roster.first.isPresent, isTrue);
      expect(rosterCtrl.hasUnsavedChanges.value, isTrue);
      expect(rosterCtrl.presentCount, greaterThanOrEqualTo(1));

      rosterCtrl.updateStudentStatus(studentId, 'late');
      expect(rosterCtrl.roster.first.isLate, isTrue);

      rosterCtrl.updateStudentStatus(studentId, 'absent');
      expect(rosterCtrl.roster.first.isAbsent, isTrue);
    });

    test(
      'markRemainingPresent fills unmarked students without overriding existing marked',
      () {
        // Mark first student as absent
        final firstId = rosterCtrl.roster.first.id;
        rosterCtrl.updateStudentStatus(firstId, 'absent');

        // Bulk mark remaining
        rosterCtrl.markRemainingPresent();

        // First student must remain absent
        expect(rosterCtrl.roster.first.isAbsent, isTrue);
        // All other students must now be present
        for (int i = 1; i < rosterCtrl.roster.length; i++) {
          expect(rosterCtrl.roster[i].isPresent, isTrue);
        }
        expect(rosterCtrl.unmarkedCount, 0);
      },
    );

    test('clearAllMarks resets all attendance states to unmarked', () {
      rosterCtrl.markRemainingPresent();
      expect(rosterCtrl.unmarkedCount, 0);

      rosterCtrl.clearAllMarks();
      expect(rosterCtrl.unmarkedCount, 12);
      expect(rosterCtrl.presentCount, 0);
      expect(rosterCtrl.absentCount, 0);
      expect(rosterCtrl.lateCount, 0);
    });

    test('saveDraft persists changes and clears unsaved indicator', () async {
      final firstId = rosterCtrl.roster.first.id;
      rosterCtrl.updateStudentStatus(firstId, 'present');
      expect(rosterCtrl.hasUnsavedChanges.value, isTrue);

      await rosterCtrl.saveDraft();
      expect(rosterCtrl.hasUnsavedChanges.value, isFalse);
    });

    test(
      'Repository finalizeSession converts unmarked to absent, locks roster, and updates session',
      () async {
        // Mark 3 students present, 1 late, rest unmarked
        rosterCtrl.updateStudentStatus(rosterCtrl.roster[0].id, 'present');
        rosterCtrl.updateStudentStatus(rosterCtrl.roster[1].id, 'present');
        rosterCtrl.updateStudentStatus(rosterCtrl.roster[2].id, 'present');
        rosterCtrl.updateStudentStatus(rosterCtrl.roster[3].id, 'late');

        final finalized = await repo.finalizeSession(
          rosterCtrl.session.value.id,
          rosterCtrl.roster,
        );
        rosterCtrl.session.value = finalized;
        final reloaded = await repo.getSessionRoster(
          rosterCtrl.session.value.id,
        );
        rosterCtrl.roster.assignAll(reloaded);

        expect(rosterCtrl.session.value.isFinalized, isTrue);
        expect(rosterCtrl.unmarkedCount, 0);
        expect(rosterCtrl.presentCount, 3);
        expect(rosterCtrl.lateCount, 1);
        expect(rosterCtrl.absentCount, 8); // Remaining 8 converted to absent

        // Once finalized, subsequent marking is prevented in controller
        rosterCtrl.updateStudentStatus(rosterCtrl.roster[0].id, 'absent');
        expect(rosterCtrl.roster[0].isPresent, isTrue); // Remained present
      },
    );
  });

  group('Teacher UI Widget Tests', () {
    setUp(() async {
      Get.reset();
      Get.testMode = true;
      Get.put(ApiClient(secureStore: SecureStore()));
      Get.put(AuthController());
      final teacherCtrl = TeacherController(
        repo: TeacherRepository(simulateDelay: false),
      );
      Get.put(teacherCtrl);
      await teacherCtrl.loadAll(showSpinner: false);
    });

    tearDown(() {
      Get.reset();
      Get.testMode = true;
    });

    testWidgets(
      'TeacherHomeTab renders greeting, metrics, and session highlights',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            home: const Scaffold(body: TeacherHomeTab()),
          ),
        );
        await tester.pump();

        expect(find.textContaining('Dr. Evelyn Reed'), findsOneWidget);
        expect(find.text("Today's Sessions"), findsOneWidget);
        expect(find.text('Next Scheduled Class'), findsOneWidget);
        expect(find.text('Take Class Attendance'), findsOneWidget);
      },
    );

    testWidgets('TeacherSessionsTab displays filters and session list cards', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(body: TeacherSessionsTab()),
        ),
      );
      await tester.pump();

      expect(find.text('All'), findsOneWidget);
      expect(find.text('Open'), findsWidgets);
      expect(find.text('Upcoming'), findsWidgets);
      expect(find.text('Finalized'), findsWidgets);
      expect(find.text('CS-301'), findsWidgets);
    });

    testWidgets(
      'TeacherTimetableTab displays day selector and scheduled slots',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            home: const Scaffold(body: TeacherTimetableTab()),
          ),
        );
        await tester.pump();

        expect(find.text('Mon'), findsOneWidget);
        expect(find.text('Tue'), findsOneWidget);
        expect(find.text('Wed'), findsOneWidget);
        expect(find.text('Thu'), findsOneWidget);
        expect(find.text('Fri'), findsOneWidget);
      },
    );

    testWidgets('TeacherCoursesTab displays assigned courses and search bar', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(body: TeacherCoursesTab()),
        ),
      );
      await tester.pump();

      expect(find.byType(AppSearchField), findsOneWidget);
      expect(find.text('CS-301'), findsOneWidget);
      expect(find.text('CS-302'), findsOneWidget);
      expect(find.text('CS-399'), findsOneWidget);
    });

    testWidgets(
      'TeacherCourseDetailView renders course info, syllabus, and roster',
      (tester) async {
        final teacherCtrl = Get.find<TeacherController>();
        final course = teacherCtrl.courses.first;

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            home: TeacherCourseDetailView(course: course),
          ),
        );
        await tester.pump();

        expect(find.text('CS-301'), findsNWidgets(2));
        expect(
          find.text('Distributed Systems & Cloud Computing'),
          findsOneWidget,
        );
        expect(find.text('Class Logistics'), findsOneWidget);
        expect(find.text('Syllabus & Course Objectives'), findsOneWidget);
        expect(
          find.text('Enrolled Student Roster', skipOffstage: false),
          findsOneWidget,
        );
        expect(find.text('Faizan Khan', skipOffstage: false), findsOneWidget);
      },
    );

    testWidgets(
      'TeacherRosterView renders student attendance row with P/L/A controls',
      (tester) async {
        final teacherCtrl = Get.find<TeacherController>();
        final session = teacherCtrl.sessions.firstWhere(
          (s) => s.id == 'sess-today-open',
        );

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            home: TeacherRosterView(session: session),
          ),
        );
        await tester.pump();

        expect(find.text('CS-301 Attendance Roster'), findsOneWidget);
        expect(find.text('Faizan Khan'), findsOneWidget);
        expect(find.text('BSIT-MC-0001'), findsOneWidget);
        expect(find.textContaining('Present'), findsWidgets);
        expect(find.textContaining('Late'), findsWidgets);
        expect(find.textContaining('Absent'), findsWidgets);
        expect(find.text('Save Draft'), findsOneWidget);
        expect(find.text('Review & Finalize'), findsOneWidget);
      },
    );

    testWidgets('TeacherShellView initializes with 4 tabs and faculty badge', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(theme: AppTheme.light, home: const TeacherShellView()),
      );
      await tester.pump();

      expect(find.text('Uni Secure'), findsOneWidget);
      expect(find.text('FACULTY'), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Sessions'), findsOneWidget);
      expect(find.text('Timetable'), findsOneWidget);
      expect(find.text('Courses'), findsOneWidget);
    });
  });
}
