import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unisecure_app/app/core/theme/app_theme.dart';
import 'package:unisecure_app/app/data/models/guard_models.dart';
import 'package:unisecure_app/app/data/repositories/guard_repository.dart';
import 'package:unisecure_app/app/modules/guard/controllers/guard_controller.dart';
import 'package:unisecure_app/app/modules/guard/controllers/guard_verification_controller.dart';
import 'package:unisecure_app/app/modules/guard/controllers/guard_visitor_controller.dart';
import 'package:unisecure_app/app/modules/guard/views/guard_shell_view.dart';
import 'package:unisecure_app/app/modules/guard/views/tabs/guard_gate_tab.dart';
import 'package:unisecure_app/app/modules/guard/views/tabs/guard_history_tab.dart';
import 'package:unisecure_app/app/modules/guard/views/tabs/guard_profile_tab.dart';
import 'package:unisecure_app/app/modules/guard/views/tabs/guard_visitors_tab.dart';
import 'package:unisecure_app/app/modules/guard/views/verification/guard_face_scan_view.dart';
import 'package:unisecure_app/app/modules/guard/views/verification/guard_manual_verification_view.dart';
import 'package:unisecure_app/app/modules/guard/views/visitors/guard_register_visitor_view.dart';
import 'package:unisecure_app/app/modules/guard/views/visitors/guard_visitor_detail_view.dart';
import 'package:unisecure_app/core/api/api_client.dart';
import 'package:unisecure_app/core/auth/auth_controller.dart';
import 'package:unisecure_app/core/storage/secure_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
  Get.testMode = true;

  group('GuardRepository & Models Tests', () {
    final repo = GuardRepository(simulateDelay: false);

    test('getProfile returns valid security officer profile', () async {
      final profile = await repo.getProfile();
      expect(profile.name, 'Officer Tariq Khan');
      expect(profile.guardIdNumber, 'SEC-2022-004');
      expect(profile.assignedGate, 'Main Gate 1 (North Entrance)');
      expect(profile.isActive, isTrue);
    });

    test('getSummary calculates live gate desk operational metrics', () async {
      final summary = await repo.getSummary();
      expect(summary.assignedGate, contains('Main Gate 1'));
      expect(summary.todayEntryCount, greaterThanOrEqualTo(1));
      expect(summary.activeVisitorsCount, greaterThanOrEqualTo(1));
    });

    test('getRecentTransactions returns chronological gate events', () async {
      final recent = await repo.getRecentTransactions(limit: 5);
      expect(recent.length, lessThanOrEqualTo(5));
      expect(recent.first.gate, contains('Main Gate 1'));
      expect(recent.first.isSimulated, isTrue);
    });

    test('getTransactions filters by direction and subject type', () async {
      final entries = await repo.getTransactions(eventTypeFilter: 'entry');
      expect(entries.every((tx) => tx.isEntry), isTrue);

      final exits = await repo.getTransactions(eventTypeFilter: 'exit');
      expect(exits.every((tx) => tx.isExit), isTrue);

      final visitors = await repo.getTransactions(subjectFilter: 'visitor');
      expect(visitors.every((tx) => tx.isVisitor), isTrue);
    });

    test('searchStudents filters registered student cards', () async {
      final results = await repo.searchStudents('faizan');
      expect(results.length, 1);
      expect(results.first.name, 'Faizan Khan');
      expect(results.first.studentIdNumber, 'BSIT-MC-0001');
      expect(results.first.isValid, isTrue);
    });

    test('getStudentById retrieves student card by ID number', () async {
      final student = await repo.getStudentById('CS-2023-0105');
      expect(student, isNotNull);
      expect(student?.name, 'Priya Patel');
      expect(student?.lastTransaction, isNotNull);
    });

    test('recordStudentTransaction appends simulated transaction', () async {
      final tx = await repo.recordStudentTransaction(
        studentId: 'stu-001',
        eventType: 'exit',
        method: 'manual_guard',
        notes: 'Test exit record',
      );

      expect(tx.isExit, isTrue);
      expect(tx.subjectName, 'Faizan Khan');
      expect(tx.verificationMethod, 'manual_guard');
      expect(tx.isSimulated, isTrue);

      // Verify updated student lastTransaction
      final updatedStudent = await repo.getStudentById('stu-001');
      expect(updatedStudent?.lastTransaction?.eventType, 'exit');
    });

    test('getVisitors filters active and checked out visitors', () async {
      final active = await repo.getVisitors(statusFilter: 'active');
      expect(active.every((v) => v.isActive), isTrue);

      final checkedOut = await repo.getVisitors(statusFilter: 'checked_out');
      expect(checkedOut.every((v) => v.isCheckedOut), isTrue);
    });

    test('registerVisitor issues new pass and logs entry audit', () async {
      final visitor = await repo.registerVisitor(
        name: 'Dr. Alan Grant',
        phone: '+1 (555) 998-1122',
        purpose: 'Guest Lecture in Geology',
        hostDepartmentOrPerson: 'Earth Sciences Block',
        idProofType: 'National ID',
        idProofNumber: 'GEO-4401-22',
        vehicleNumber: 'JEEP-01',
      );

      expect(visitor.badgeNumber, startsWith('VIS-'));
      expect(visitor.isActive, isTrue);

      // Check that an entry audit transaction was created
      final txs = await repo.getTransactions(query: 'Dr. Alan Grant');
      expect(txs.isNotEmpty, isTrue);
      expect(txs.first.isEntry, isTrue);
    });

    test(
      'checkOutVisitor marks status checked_out and logs exit audit',
      () async {
        final activeList = await repo.getVisitors(statusFilter: 'active');
        final target = activeList.first;

        final checkedOut = await repo.checkOutVisitor(target.id);
        expect(checkedOut.isCheckedOut, isTrue);
        expect(checkedOut.checkOutTime, isNotNull);

        // Check exit transaction
        final txs = await repo.getTransactions(query: target.name);
        expect(txs.any((tx) => tx.isExit), isTrue);
      },
    );
  });

  group('GuardController State Tests', () {
    late GuardController controller;

    setUp(() async {
      Get.reset();
      Get.testMode = true;
      controller = GuardController(repo: GuardRepository(simulateDelay: false));
      Get.put(controller);
      await controller.loadAll(showSpinner: false);
    });

    tearDown(() {
      Get.reset();
      Get.testMode = true;
    });

    test('Initial state loads officer profile, summary, and transactions', () {
      expect(controller.profile.value?.name, 'Officer Tariq Khan');
      expect(
        controller.deskSummary.value?.assignedGate,
        contains('Main Gate 1'),
      );
      expect(controller.recentTransactions.isNotEmpty, isTrue);
      expect(controller.allTransactions.isNotEmpty, isTrue);
    });

    test('Tab switching updates currentTabIndex', () {
      expect(controller.currentTabIndex.value, 0);
      controller.changeTab(1);
      expect(controller.currentTabIndex.value, 1);
      controller.changeTab(2);
      expect(controller.currentTabIndex.value, 2);
    });

    test('History event filter updates transaction stream', () async {
      await controller.filterHistoryEvent('Exit');
      expect(controller.selectedEventFilter.value, 'Exit');
      expect(controller.allTransactions.every((tx) => tx.isExit), isTrue);

      await controller.filterHistoryEvent('All');
      expect(controller.allTransactions.length, greaterThanOrEqualTo(5));
    });

    test('History search query filters records', () async {
      await controller.searchHistory('Sanjay');
      expect(controller.allTransactions.length, 1);
      expect(controller.allTransactions.first.subjectName, 'Sanjay Deshmukh');
    });
  });

  group('GuardVerificationController & Simulation Tests', () {
    late GuardRepository repo;
    late GuardVerificationController verifCtrl;

    setUp(() async {
      Get.reset();
      Get.testMode = true;
      repo = GuardRepository(simulateDelay: false);
      verifCtrl = GuardVerificationController(repo: repo);
      Get.put(verifCtrl);
      await verifCtrl.searchStudents('');
    });

    tearDown(() {
      Get.reset();
      Get.testMode = true;
    });

    test(
      'Student search returns matching results and empty queries list all',
      () async {
        expect(verifCtrl.searchResults.isNotEmpty, isTrue);

        await verifCtrl.searchStudents('Priya');
        expect(verifCtrl.searchResults.length, 1);
        expect(verifCtrl.searchResults.first.name, 'Priya Patel');
      },
    );

    test('Student selection updates selectedStudent observable', () {
      final student = verifCtrl.searchResults.first;
      verifCtrl.selectStudent(student);
      expect(verifCtrl.selectedStudent.value?.name, student.name);

      verifCtrl.clearSelectedStudent();
      expect(verifCtrl.selectedStudent.value, isNull);
    });

    test('Direction setting toggles entry and exit states', () {
      expect(verifCtrl.selectedDirection.value, 'entry');
      verifCtrl.setDirection('exit');
      expect(verifCtrl.selectedDirection.value, 'exit');
    });

    test('resetScan returns scanner to idle state', () {
      verifCtrl.scanState.value = FaceScanState.matched;
      verifCtrl.resetScan();
      expect(verifCtrl.scanState.value, FaceScanState.idle);
      expect(verifCtrl.scannedStudent.value, isNull);
    });
  });

  group('GuardVisitorController Tests', () {
    late GuardRepository repo;
    late GuardVisitorController visitorCtrl;

    setUp(() async {
      Get.reset();
      Get.testMode = true;
      repo = GuardRepository(simulateDelay: false);
      visitorCtrl = GuardVisitorController(repo: repo);
      Get.put(visitorCtrl);
      await visitorCtrl.loadVisitors();
    });

    tearDown(() {
      Get.reset();
      Get.testMode = true;
    });

    test('Initial state loads active and departed visitors', () {
      expect(visitorCtrl.visitors.isNotEmpty, isTrue);
      expect(visitorCtrl.visitors.any((v) => v.isActive), isTrue);
    });

    test('Status filtering updates list properly', () async {
      await visitorCtrl.filterStatus('active');
      expect(visitorCtrl.visitors.every((v) => v.isActive), isTrue);

      await visitorCtrl.filterStatus('checked_out');
      expect(visitorCtrl.visitors.every((v) => v.isCheckedOut), isTrue);
    });

    test('Form validation flags missing required inputs', () {
      expect(visitorCtrl.validateRegistrationForm(), isFalse);
      expect(visitorCtrl.nameError.value.isNotEmpty, isTrue);
      expect(visitorCtrl.phoneError.value.isNotEmpty, isTrue);
    });
  });

  group('Guard UI Widget Tests', () {
    setUp(() async {
      Get.reset();
      Get.testMode = true;
      Get.put(ApiClient(secureStore: SecureStore()));
      Get.put(AuthController());
      final repo = GuardRepository(simulateDelay: false);
      final guardCtrl = GuardController(repo: repo);
      Get.put(guardCtrl);
      Get.put(GuardVerificationController(repo: repo));
      Get.put(GuardVisitorController(repo: repo));
      await guardCtrl.loadAll(showSpinner: false);
    });

    tearDown(() {
      Get.reset();
      Get.testMode = true;
    });

    testWidgets('GuardGateTab renders gate info, metrics, and actions', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(body: GuardGateTab()),
        ),
      );
      await tester.pump();

      expect(find.textContaining('Main Gate 1'), findsWidgets);
      expect(find.text('ON DUTY'), findsOneWidget);
      expect(find.text('Face Verification Preview'), findsOneWidget);
      expect(find.text('Manual Student Audit'), findsOneWidget);
      expect(find.text('Register Visitor'), findsOneWidget);
      expect(find.text("Today's Entries"), findsOneWidget);
      expect(find.text("Today's Exits"), findsOneWidget);
      expect(find.text('Active Visitors'), findsOneWidget);
      expect(
        find.text('Recent Gate Activity', skipOffstage: false),
        findsOneWidget,
      );
    });

    testWidgets(
      'GuardFaceScanView renders camera frame, disclaimer, and fallback',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(theme: AppTheme.light, home: const GuardFaceScanView()),
        );
        await tester.pump();

        expect(find.text('Face Verification Preview'), findsOneWidget);
        expect(find.text('PROTOTYPE PREVIEW ONLY'), findsOneWidget);
        expect(find.text('Align student face in frame'), findsOneWidget);
        expect(find.text('Simulate Face Match (Faizan Khan)'), findsOneWidget);
        expect(
          find.text('Manual Guard Audit Fallback', skipOffstage: false),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'GuardManualVerificationView renders student roster and search',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            home: const GuardManualVerificationView(),
          ),
        );
        await tester.pump();

        expect(find.text('Manual Student Verification'), findsOneWidget);
        expect(find.text('Faizan Khan'), findsOneWidget);
        expect(find.text('Priya Patel'), findsOneWidget);
        expect(find.text('VALID'), findsWidgets);
      },
    );

    testWidgets(
      'GuardVisitorsTab displays search, register button, and visitor cards',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            home: const Scaffold(body: GuardVisitorsTab()),
          ),
        );
        await tester.pump();

        expect(find.text('Register'), findsOneWidget);
        expect(find.text('All Visitors'), findsOneWidget);
        expect(find.text('Active on Campus'), findsOneWidget);
        expect(find.text('Checked Out'), findsOneWidget);
        expect(find.text('Sanjay Deshmukh'), findsOneWidget);
      },
    );

    testWidgets(
      'GuardRegisterVisitorView renders complete visitor registration form',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            home: const GuardRegisterVisitorView(),
          ),
        );
        await tester.pump();

        expect(find.text('Register Visitor'), findsOneWidget);
        expect(find.text('Campus Visitor Pass'), findsOneWidget);
        expect(find.text('Visitor Full Name *'), findsOneWidget);
        expect(find.text('Contact Phone Number *'), findsOneWidget);
        expect(find.text('Purpose of Visit *'), findsOneWidget);
        expect(find.text('Person / Department to Meet *'), findsOneWidget);
        expect(find.text('ID Proof Document Number *'), findsOneWidget);
        await tester.drag(find.byType(ListView), const Offset(0, -600));
        await tester.pumpAndSettle();

        expect(find.text('Issue Visitor Pass & Grant Entry'), findsOneWidget);
      },
    );

    testWidgets('GuardVisitorDetailView renders visitor pass details', (
      tester,
    ) async {
      final visitor = Visitor(
        id: 'vis-test',
        badgeNumber: 'VIS-4099',
        name: 'Dr. Jane Foster',
        phone: '+1 (555) 332-9011',
        purpose: 'Keynote Speaker at Security Symposium',
        hostDepartmentOrPerson: 'Dept of Computer Science',
        idProofType: 'Passport',
        idProofNumber: 'P-9901441',
        checkInTime: DateTime(2026, 10, 26, 9, 30),
        status: 'active',
        registeredByGate: 'Main Gate 1',
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: GuardVisitorDetailView(visitor: visitor),
        ),
      );
      await tester.pump();

      expect(find.text('VIS-4099'), findsNWidgets(2));
      expect(find.text('Dr. Jane Foster'), findsOneWidget);
      expect(find.text('ON CAMPUS'), findsOneWidget);
      expect(find.text('Check Out Visitor'), findsOneWidget);
    });

    testWidgets('GuardHistoryTab displays filters and audit transactions', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(body: GuardHistoryTab()),
        ),
      );
      await tester.pump();

      expect(find.text('All'), findsOneWidget);
      expect(find.text('Entry'), findsOneWidget);
      expect(find.text('Exit'), findsOneWidget);
      expect(find.text('Students'), findsOneWidget);
      expect(find.text('Visitors'), findsOneWidget);
      expect(find.textContaining('ENTRY • Main Gate 1'), findsWidgets);
    });

    testWidgets('GuardProfileTab renders officer credential and protocols', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(body: GuardProfileTab()),
        ),
      );
      await tester.pump();

      expect(find.text('CAMPUS SECURITY CORPS'), findsOneWidget);
      expect(find.text('Officer Tariq Khan'), findsOneWidget);
      expect(find.text('ID: SEC-2022-004'), findsOneWidget);
      expect(find.text('Standard Security Protocols'), findsOneWidget);
      expect(
        find.text('Sign Out of Gate Desk', skipOffstage: false),
        findsOneWidget,
      );
    });

    testWidgets(
      'GuardShellView initializes with 4 tabs and security desk badge',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(theme: AppTheme.light, home: const GuardShellView()),
        );
        await tester.pump();

        expect(find.text('Uni Secure'), findsOneWidget);
        expect(find.text('SECURITY DESK'), findsOneWidget);
        expect(find.text('Gate'), findsOneWidget);
        expect(find.text('Visitors'), findsOneWidget);
        expect(find.text('History'), findsOneWidget);
        expect(find.text('Profile'), findsOneWidget);
      },
    );
  });
}
