import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/widgets/app_feedback.dart';
import '../../../data/models/teacher_models.dart';
import '../../../data/repositories/teacher_repository.dart';
import 'teacher_controller.dart';

/// GetX controller managing the live attendance-marking roster and finalization workflow.
class TeacherRosterController extends GetxController {
  final TeacherSession initialSession;
  final TeacherRepository repository;

  TeacherRosterController({
    required this.initialSession,
    TeacherRepository? repo,
  }) : repository =
           repo ??
           (Get.isRegistered<TeacherController>()
               ? Get.find<TeacherController>().repository
               : TeacherRepository());

  late final session = initialSession.obs;
  final roster = <RosterStudent>[].obs;
  final isLoading = true.obs;
  final isSubmitting = false.obs;
  final hasUnsavedChanges = false.obs;
  final searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadRoster();
  }

  Future<void> loadRoster() async {
    isLoading.value = true;
    try {
      final items = await repository.getSessionRoster(session.value.id);
      roster.assignAll(items);
      hasUnsavedChanges.value = false;
    } finally {
      isLoading.value = false;
    }
  }

  void searchRoster(String query) {
    searchQuery.value = query;
  }

  List<RosterStudent> get filteredRoster {
    if (searchQuery.value.trim().isEmpty) return roster;
    final q = searchQuery.value.toLowerCase();
    return roster.where((student) {
      return student.name.toLowerCase().contains(q) ||
          student.studentIdNumber.toLowerCase().contains(q);
    }).toList();
  }

  // Live attendance counts
  int get presentCount => roster.where((s) => s.isPresent).length;
  int get lateCount => roster.where((s) => s.isLate).length;
  int get absentCount => roster.where((s) => s.isAbsent).length;
  int get unmarkedCount => roster.where((s) => s.isUnmarked).length;
  int get totalCount => roster.length;

  // Single student status toggle
  void updateStudentStatus(String studentId, String newStatus) {
    if (session.value.isFinalized) {
      AppSnackbar.showWarning(
        title: 'Session Finalized',
        message:
            'This session is locked and attendance records cannot be modified.',
      );
      return;
    }

    final index = roster.indexWhere((s) => s.id == studentId);
    if (index != -1) {
      final current = roster[index];
      // If tapping the already selected status, toggle back to unmarked
      final statusToApply = current.attendanceStatus == newStatus
          ? 'unmarked'
          : newStatus;

      roster[index] = current.copyWith(
        attendanceStatus: statusToApply,
        markedAt: DateTime.now(),
      );
      hasUnsavedChanges.value = true;
    }
  }

  // Safe Bulk Action: Only marks currently unmarked students as Present
  void markRemainingPresent() {
    if (session.value.isFinalized) return;

    var changed = 0;
    for (var i = 0; i < roster.length; i++) {
      if (roster[i].isUnmarked) {
        roster[i] = roster[i].copyWith(
          attendanceStatus: 'present',
          markedAt: DateTime.now(),
        );
        changed++;
      }
    }

    if (changed > 0) {
      hasUnsavedChanges.value = true;
      AppSnackbar.showInfo(
        title: 'Marked Remaining',
        message: '$changed unmarked students have been marked Present.',
      );
    } else {
      AppSnackbar.showInfo(
        title: 'Roster Already Complete',
        message: 'All students currently have an assigned attendance status.',
      );
    }
  }

  // Clear marks
  void clearAllMarks() {
    if (session.value.isFinalized) return;

    for (var i = 0; i < roster.length; i++) {
      roster[i] = roster[i].copyWith(attendanceStatus: 'unmarked');
    }
    hasUnsavedChanges.value = true;
    AppSnackbar.showInfo(
      title: 'Marks Reset',
      message: 'All student marks have been reset to unmarked.',
    );
  }

  // Save Draft
  Future<void> saveDraft() async {
    if (isSubmitting.value) return;
    isSubmitting.value = true;
    try {
      await repository.saveRosterDraft(session.value.id, roster);
      hasUnsavedChanges.value = false;

      // Refresh parent teacher controller if registered
      if (Get.isRegistered<TeacherController>()) {
        Get.find<TeacherController>().refreshData();
      }

      AppSnackbar.showSuccess(
        title: 'Draft Saved Locally',
        message: 'Session attendance draft has been updated in local state.',
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  // Finalize attendance workflow
  Future<void> finalizeAttendance(BuildContext context) async {
    if (session.value.isFinalized) {
      AppSnackbar.showInfo(
        title: 'Already Finalized',
        message: 'This session has already been finalized and locked.',
      );
      return;
    }

    final confirmed = await _showFinalizationReviewSheet(context);
    if (confirmed != true) return;

    isSubmitting.value = true;
    try {
      final updated = await repository.finalizeSession(
        session.value.id,
        roster,
      );
      session.value = updated;
      hasUnsavedChanges.value = false;

      // Reload roster to show auto-absences
      final items = await repository.getSessionRoster(session.value.id);
      roster.assignAll(items);

      // Refresh parent teacher controller
      if (Get.isRegistered<TeacherController>()) {
        Get.find<TeacherController>().refreshData();
      }

      AppSnackbar.showSuccess(
        title: 'Attendance Finalized',
        message:
            'Session attendance has been locked. Records finalized locally.',
      );

      // Wait a moment then pop
      await Future.delayed(const Duration(milliseconds: 400));
      if (Get.isOverlaysOpen) Get.back();
      Get.back();
    } catch (e) {
      AppSnackbar.showError(
        title: 'Finalization Error',
        message: 'Unable to finalize attendance: $e',
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<bool?> _showFinalizationReviewSheet(BuildContext context) {
    final p = presentCount;
    final l = lateCount;
    final a = absentCount;
    final u = unmarkedCount;

    return AppBottomSheet.showConfirmation(
      context: context,
      title: 'Finalize Session Attendance?',
      message:
          'Attendance summary: $p Present, $l Late, $a Absent.\n\n${u > 0 ? '⚠️ Notice: $u unmarked students will automatically be recorded as Absent.' : 'All students have been reviewed.'}\n\nOnce finalized, this session will be permanently locked from mobile edits.',
      confirmText: 'Lock & Finalize',
      cancelText: 'Continue Review',
      isDestructive: false,
      icon: AppIcons.check,
    );
  }
}
