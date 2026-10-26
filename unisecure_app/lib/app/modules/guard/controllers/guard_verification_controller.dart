import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/widgets/app_feedback.dart';
import '../../../data/models/guard_models.dart';
import '../../../data/repositories/guard_repository.dart';
import 'guard_controller.dart';

enum FaceScanState { idle, scanning, matched, error }

/// GetX controller managing Face Scan simulation preview and Manual Student Verification workflows.
class GuardVerificationController extends GetxController {
  final GuardRepository repository;

  GuardVerificationController({GuardRepository? repo})
    : repository =
          repo ??
          (Get.isRegistered<GuardController>()
              ? Get.find<GuardController>().repository
              : GuardRepository());

  // --- Face Scan Simulation State ---
  final scanState = FaceScanState.idle.obs;
  final scannedStudent = Rxn<StudentVerificationCard>();
  final scanErrorMessage = ''.obs;

  // --- Manual Student Search & Audit State ---
  final searchQuery = ''.obs;
  final isSearching = false.obs;
  final searchResults = <StudentVerificationCard>[].obs;
  final selectedStudent = Rxn<StudentVerificationCard>();

  // Transaction Configuration
  final selectedDirection = 'entry'.obs; // 'entry' or 'exit'
  final auditReasonText = ''.obs;
  final isSubmitting = false.obs;
  final lastRecordedTransaction = Rxn<GateTransaction>();

  @override
  void onInit() {
    super.onInit();
    // Pre-populate with all students on initial search view
    searchStudents('');
  }

  // --- Face Scan Actions ---
  Future<void> triggerSimulatedScan() async {
    if (scanState.value == FaceScanState.scanning) return;

    scanState.value = FaceScanState.scanning;
    scanErrorMessage.value = '';
    scannedStudent.value = null;

    // Simulate viewfinder analysis delay
    await Future.delayed(const Duration(milliseconds: 1400));

    // For prototype preview, simulate matching Faizan Khan
    final student = await repository.getStudentById('stu-001');
    if (student != null) {
      scannedStudent.value = student;
      scanState.value = FaceScanState.matched;
    } else {
      scanErrorMessage.value =
          'Biometric camera verification service is offline. Please proceed with manual guard verification.';
      scanState.value = FaceScanState.error;
    }
  }

  void resetScan() {
    scanState.value = FaceScanState.idle;
    scannedStudent.value = null;
    scanErrorMessage.value = '';
  }

  // --- Manual Student Search Actions ---
  Future<void> searchStudents(String query) async {
    searchQuery.value = query;
    isSearching.value = true;
    try {
      if (query.trim().isEmpty) {
        // Show all default students if query is empty
        final list = await repository.searchStudents(' ');
        if (list.isEmpty) {
          // If empty query returns nothing, search with partial query
          final all = await Future.wait([
            repository.getStudentById('stu-001'),
            repository.getStudentById('stu-002'),
            repository.getStudentById('stu-003'),
            repository.getStudentById('stu-004'),
            repository.getStudentById('stu-005'),
            repository.getStudentById('stu-006'),
          ]);
          searchResults.assignAll(all.whereType<StudentVerificationCard>());
        } else {
          searchResults.assignAll(list);
        }
      } else {
        final list = await repository.searchStudents(query);
        searchResults.assignAll(list);
      }
    } finally {
      isSearching.value = false;
    }
  }

  void selectStudent(StudentVerificationCard student) {
    selectedStudent.value = student;
    auditReasonText.value =
        'Identity verified with active university digital card.';
  }

  void clearSelectedStudent() {
    selectedStudent.value = null;
    auditReasonText.value = '';
  }

  void setDirection(String direction) {
    selectedDirection.value = direction;
  }

  // --- Transaction Recording Workflow ---
  Future<bool> confirmAndRecordTransaction({
    required BuildContext context,
    required StudentVerificationCard student,
    required String method, // 'face_scan' or 'manual_guard'
  }) async {
    if (isSubmitting.value) return false;

    final directionLabel = selectedDirection.value == 'entry'
        ? 'Entry'
        : 'Exit';

    final confirmed = await AppBottomSheet.showConfirmation(
      context: context,
      title: 'Confirm Student $directionLabel?',
      message:
          'Record simulated $directionLabel for ${student.name} (${student.studentIdNumber}) at Main Gate 1 via ${method == 'face_scan' ? 'Face Scan' : 'Manual Guard Audit'}.\n\n⚠️ Notice: This will update the local prototype audit trail.',
      confirmText: 'Confirm $directionLabel',
      cancelText: 'Cancel',
      isDestructive: false,
      icon: AppIcons.guard,
    );

    if (confirmed != true) return false;

    isSubmitting.value = true;
    try {
      final tx = await repository.recordStudentTransaction(
        studentId: student.id,
        eventType: selectedDirection.value,
        method: method,
        notes: auditReasonText.value.isNotEmpty
            ? auditReasonText.value
            : 'Simulated ${selectedDirection.value} confirmed by officer',
      );

      lastRecordedTransaction.value = tx;

      // Refresh parent GuardController if registered
      if (Get.isRegistered<GuardController>()) {
        Get.find<GuardController>().refreshDesk();
      }

      AppSnackbar.showSuccess(
        title: '$directionLabel Recorded (Simulated)',
        message:
            '${student.name} has been logged as $directionLabel at ${tx.timeFormatted}.',
      );

      return true;
    } catch (e) {
      AppSnackbar.showError(
        title: 'Transaction Error',
        message: 'Failed to record simulated transaction: $e',
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }
}
