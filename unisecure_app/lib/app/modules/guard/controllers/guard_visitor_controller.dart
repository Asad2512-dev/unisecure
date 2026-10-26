import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/widgets/app_feedback.dart';
import '../../../data/models/guard_models.dart';
import '../../../data/repositories/guard_repository.dart';
import 'guard_controller.dart';

/// GetX controller managing Visitor rosters, registrations, and checkout actions.
class GuardVisitorController extends GetxController {
  final GuardRepository repository;

  GuardVisitorController({GuardRepository? repo})
    : repository =
          repo ??
          (Get.isRegistered<GuardController>()
              ? Get.find<GuardController>().repository
              : GuardRepository());

  final visitors = <Visitor>[].obs;
  final isLoading = true.obs;
  final isSubmitting = false.obs;

  // Filter & Search
  final selectedStatusFilter = 'All'.obs; // All, active, checked_out
  final searchQuery = ''.obs;

  // Registration Form Controllers
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final purposeController = TextEditingController();
  final hostController = TextEditingController();
  final idProofNumberController = TextEditingController();
  final vehicleController = TextEditingController();
  final selectedIdProofType = 'National ID'.obs;

  // Form Validation Errors
  final nameError = ''.obs;
  final phoneError = ''.obs;
  final purposeError = ''.obs;
  final hostError = ''.obs;
  final idProofError = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadVisitors();
  }

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    purposeController.dispose();
    hostController.dispose();
    idProofNumberController.dispose();
    vehicleController.dispose();
    super.onClose();
  }

  Future<void> loadVisitors() async {
    isLoading.value = true;
    try {
      final list = await repository.getVisitors(
        statusFilter: selectedStatusFilter.value == 'All'
            ? null
            : selectedStatusFilter.value,
        query: searchQuery.value,
      );
      visitors.assignAll(list);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> filterStatus(String status) async {
    selectedStatusFilter.value = status;
    await loadVisitors();
  }

  Future<void> searchVisitors(String query) async {
    searchQuery.value = query;
    await loadVisitors();
  }

  bool validateRegistrationForm() {
    var valid = true;
    nameError.value = '';
    phoneError.value = '';
    purposeError.value = '';
    hostError.value = '';
    idProofError.value = '';

    if (nameController.text.trim().length < 3) {
      nameError.value =
          'Please enter a valid visitor full name (min 3 characters).';
      valid = false;
    }

    if (phoneController.text.trim().length < 7) {
      phoneError.value = 'Please enter a valid contact phone number.';
      valid = false;
    }

    if (purposeController.text.trim().length < 4) {
      purposeError.value = 'Please specify the exact purpose of campus visit.';
      valid = false;
    }

    if (hostController.text.trim().length < 3) {
      hostError.value =
          'Please specify the department or host personnel to meet.';
      valid = false;
    }

    if (idProofNumberController.text.trim().length < 3) {
      idProofError.value =
          'Please provide the physical ID document reference number.';
      valid = false;
    }

    return valid;
  }

  Future<bool> submitVisitorRegistration(BuildContext context) async {
    if (!validateRegistrationForm()) return false;
    if (isSubmitting.value) return false;

    isSubmitting.value = true;
    try {
      final visitor = await repository.registerVisitor(
        name: nameController.text.trim(),
        phone: phoneController.text.trim(),
        purpose: purposeController.text.trim(),
        hostDepartmentOrPerson: hostController.text.trim(),
        idProofType: selectedIdProofType.value,
        idProofNumber: idProofNumberController.text.trim(),
        vehicleNumber: vehicleController.text.trim().isNotEmpty
            ? vehicleController.text.trim()
            : null,
      );

      // Reset form fields
      nameController.clear();
      phoneController.clear();
      purposeController.clear();
      hostController.clear();
      idProofNumberController.clear();
      vehicleController.clear();

      await loadVisitors();

      // Refresh parent GuardController desk summary
      if (Get.isRegistered<GuardController>()) {
        Get.find<GuardController>().refreshDesk();
      }

      AppSnackbar.showSuccess(
        title: 'Visitor Pass Issued',
        message: 'Badge ${visitor.badgeNumber} granted for ${visitor.name}.',
      );

      return true;
    } catch (e) {
      AppSnackbar.showError(
        title: 'Registration Error',
        message: 'Unable to register visitor: $e',
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> checkoutVisitor({
    required BuildContext context,
    required Visitor visitor,
  }) async {
    final confirmed = await AppBottomSheet.showConfirmation(
      context: context,
      title: 'Check Out Visitor?',
      message:
          'Confirm departure for ${visitor.name} (Badge: ${visitor.badgeNumber}).\n\nThis will record exit at Main Gate 1 and update campus visitor occupancy.',
      confirmText: 'Confirm Departure',
      cancelText: 'Cancel',
      isDestructive: false,
      icon: AppIcons.logout,
    );

    if (confirmed != true) return;

    try {
      await repository.checkOutVisitor(visitor.id);
      await loadVisitors();

      if (Get.isRegistered<GuardController>()) {
        Get.find<GuardController>().refreshDesk();
      }

      AppSnackbar.showSuccess(
        title: 'Visitor Checked Out',
        message: '${visitor.name} departure has been logged.',
      );
    } catch (e) {
      AppSnackbar.showError(
        title: 'Checkout Error',
        message: 'Failed to checkout visitor: $e',
      );
    }
  }
}
