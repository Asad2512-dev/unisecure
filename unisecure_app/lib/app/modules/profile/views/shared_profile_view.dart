import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/auth/auth_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/app_cards.dart';
import '../../../core/widgets/app_feedback.dart';
import '../../../core/widgets/app_headers.dart';
import '../../../core/widgets/app_layout.dart';
import '../../../core/widgets/app_status_badge.dart';

/// Centralized, role-adaptive profile view for Student, Teacher, and Guard accounts.
class SharedProfileView extends StatelessWidget {
  final String? overrideRole;

  const SharedProfileView({super.key, this.overrideRole});

  String _resolveRole(AuthController? auth) {
    if (overrideRole != null && overrideRole!.isNotEmpty) {
      return overrideRole!.toLowerCase();
    }
    final userRole = auth?.user.value?.role;
    if (userRole != null && userRole.isNotEmpty) {
      return userRole.toLowerCase();
    }
    return 'student';
  }

  @override
  Widget build(BuildContext context) {
    final auth = Get.isRegistered<AuthController>()
        ? Get.find<AuthController>()
        : null;
    final role = _resolveRole(auth);

    return AppScaffold(
      appBar: AppBar(
        title: Text(
          role == 'student'
              ? 'Student Profile'
              : (role == 'teacher'
                    ? 'Faculty Profile'
                    : 'Security Officer Profile'),
        ),
      ),
      body: ListView(
        padding: AppSpacing.screen,
        children: [
          // 1. Digital University Credential Card
          _buildCredentialCard(role, auth),
          AppSpacing.vGap24,

          // 2. Role-Specific Academic / Operational Details
          if (role == 'student') ...[
            const AppSectionHeader(
              title: 'Academic Standing',
              subtitle: 'Current degree enrollment and university standing',
            ),
            AppSpacing.vGap10,
            _buildStudentAcademicCard(),
          ] else if (role == 'teacher') ...[
            const AppSectionHeader(
              title: 'Faculty Assignment',
              subtitle: 'Departmental appointment and office details',
            ),
            AppSpacing.vGap10,
            _buildTeacherFacultyCard(),
          ] else ...[
            const AppSectionHeader(
              title: 'Security Perimeter Assignment',
              subtitle: 'Active gate desk station and duty schedule',
            ),
            AppSpacing.vGap10,
            _buildGuardOperationalCard(),
          ],
          AppSpacing.vGap24,

          // 3. Account Details Section
          const AppSectionHeader(
            title: 'Account & Security Information',
            subtitle: 'Institutional credentials and security profile',
          ),
          AppSpacing.vGap10,
          _buildAccountCard(role, auth),
          AppSpacing.vGap24,

          // 4. System & App Specifications
          const AppSectionHeader(
            title: 'Application Information',
            subtitle: 'System environment and version specification',
          ),
          AppSpacing.vGap10,
          _buildAppInfoCard(),
          AppSpacing.vGap24,

          // 5. Sign Out Trigger
          AppButton.outlined(
            text: 'Sign Out of Account',
            icon: Icons.logout_rounded,
            onPressed: () async {
              final confirmed = await AppBottomSheet.showConfirmation(
                context: context,
                title: 'Sign Out?',
                message:
                    'Are you sure you want to end your current active mobile session?',
                confirmText: 'Sign Out',
                cancelText: 'Stay Signed In',
                isDestructive: true,
                icon: AppIcons.logout,
              );
              if (confirmed == true && auth != null) {
                await auth.logout();
              }
            },
          ),
          AppSpacing.vGap24,
        ],
      ),
    );
  }

  Widget _buildCredentialCard(String role, AuthController? auth) {
    final String name;
    final String email;
    final String idNumber;
    final String roleLabel;
    final Color roleColor;
    final String statusLabel;

    switch (role) {
      case 'teacher':
        name = auth?.user.value?.name ?? 'Dr. Evelyn Reed';
        email = auth?.user.value?.email ?? 'e.reed@faculty.unisecure.edu';
        idNumber = 'FAC-CS-104';
        roleLabel = 'FACULTY';
        roleColor = AppColors.teacherAccent;
        statusLabel = 'ACTIVE • FULL-TIME';
        break;
      case 'guard':
        name = auth?.user.value?.name ?? 'Officer Tariq Khan';
        email = auth?.user.value?.email ?? 'tariq.guard@security.unisecure.edu';
        idNumber = 'SEC-2022-004';
        roleLabel = 'SECURITY';
        roleColor = AppColors.guardAccent;
        statusLabel = 'ON DUTY • MAIN GATE 1';
        break;
      case 'student':
      default:
        name = auth?.user.value?.name ?? 'Faizan Khan';
        email = auth?.user.value?.email ?? 'student@gmail.com';
        idNumber = 'BSIT-MC-0001';
        roleLabel = 'STUDENT';
        roleColor = AppColors.primary;
        statusLabel = 'ENROLLED • SEMESTER 4';
        break;
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: roleColor.withValues(alpha: 0.3),
          width: AppDimensions.strokeWidthThick,
        ),
        boxShadow: [
          BoxShadow(
            color: roleColor.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Crest Header Strip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              color: roleColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppRadius.card - 2),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.school, color: Colors.white, size: 18),
                      AppSpacing.hGap8,
                      Flexible(
                        child: Text(
                          'NUML UNIVERSITY',
                          style: AppTypography.labelSmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                AppSpacing.hGap8,
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Text(
                    roleLabel,
                    style: AppTypography.labelSmall.copyWith(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Identity Details
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                AppAvatar(
                  name: name,
                  size: 70,
                  role: role,
                  badgeIcon: role == 'guard'
                      ? Icons.shield_rounded
                      : (role == 'teacher'
                            ? Icons.verified_rounded
                            : Icons.check_circle_rounded),
                  badgeColor: AppColors.success,
                ),
                AppSpacing.hGap16,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: AppTypography.titleLarge.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      AppSpacing.vGap4,
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceSubtle,
                          borderRadius: BorderRadius.circular(AppRadius.xs),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Text(
                          'ID: $idNumber',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.mainText,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      AppSpacing.vGap4,
                      Text(
                        email,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.secondaryText,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      AppSpacing.vGap8,
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: AppStatusBadge(
                          label: statusLabel,
                          color: role == 'guard'
                              ? AppColors.success
                              : AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentAcademicCard() {
    return const AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _ProfileInfoTile(
            label: 'Program',
            value: 'BS Information Technology (BSIT)',
          ),
          AppDivider(),
          _ProfileInfoTile(
            label: 'Department',
            value: 'Department of Information Technology',
          ),
          AppDivider(),
          _ProfileInfoTile(
            label: 'Current Standing',
            value: 'Semester 4 • Section MC',
          ),
          AppDivider(),
          _ProfileInfoTile(
            label: 'Cumulative GPA',
            value: '3.82 / 4.00 (Distinction)',
          ),
          AppDivider(),
          _ProfileInfoTile(
            label: 'Academic Advisor',
            value: 'Dr. Katherine Vance',
          ),
          AppDivider(),
          _ProfileInfoTile(
            label: 'Enrolled Credits',
            value: '21 Credit Hours (Full-Time)',
          ),
          AppDivider(),
          _ProfileInfoTile(
            label: 'Access Clearance',
            value: 'Full Campus Access (Biometric Enrolled)',
          ),
        ],
      ),
    );
  }

  Widget _buildTeacherFacultyCard() {
    return const AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _ProfileInfoTile(
            label: 'Department',
            value: 'Department of Computer Science & Engineering',
          ),
          AppDivider(),
          _ProfileInfoTile(
            label: 'Designation',
            value: 'Associate Professor & Course Lead',
          ),
          AppDivider(),
          _ProfileInfoTile(
            label: 'Specialization',
            value: 'Software Architecture & Distributed Systems',
          ),
          AppDivider(),
          _ProfileInfoTile(
            label: 'Faculty Office',
            value: 'Engineering Block B, Room 314',
          ),
          AppDivider(),
          _ProfileInfoTile(
            label: 'Office Hours',
            value: 'Mon & Wed: 14:00 - 16:00',
          ),
          AppDivider(),
          _ProfileInfoTile(
            label: 'Assigned Courses',
            value: '3 Active Courses • 4 Sections',
          ),
          AppDivider(),
          _ProfileInfoTile(
            label: 'Faculty Clearance',
            value: 'Departmental Labs & Research Block Access',
          ),
        ],
      ),
    );
  }

  Widget _buildGuardOperationalCard() {
    return const AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _ProfileInfoTile(
            label: 'Security Division',
            value: 'Campus Security Corps • Perimeter Division',
          ),
          AppDivider(),
          _ProfileInfoTile(
            label: 'Assigned Gate Desk',
            value: 'Main Gate 1 (North Entrance)',
          ),
          AppDivider(),
          _ProfileInfoTile(
            label: 'Active Shift',
            value: 'Morning Shift • 06:00 - 14:00',
          ),
          AppDivider(),
          _ProfileInfoTile(
            label: 'Radio Channel',
            value: 'Channel 4 (Campus Perimeter)',
          ),
          AppDivider(),
          _ProfileInfoTile(
            label: 'Gate Phone Line',
            value: '+1 (555) 019-3382',
          ),
          AppDivider(),
          _ProfileInfoTile(
            label: 'Shift Supervisor',
            value: 'Captain R. Daniels',
          ),
          AppDivider(),
          _ProfileInfoTile(
            label: 'Gate Authority',
            value: 'Turnstile Override & Visitor Pass Issuance',
          ),
        ],
      ),
    );
  }

  Widget _buildAccountCard(String role, AuthController? auth) {
    final email =
        auth?.user.value?.email ??
        (role == 'student'
            ? 'aarav.sharma@campus.unisecure.edu'
            : (role == 'teacher'
                  ? 'e.reed@faculty.unisecure.edu'
                  : 'tariq.guard@security.unisecure.edu'));

    final phone = role == 'student'
        ? '+1 (555) 019-2834'
        : (role == 'teacher' ? '+1 (555) 019-8831' : '+1 (555) 019-3382');

    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _ProfileInfoTile(label: 'Institutional Email', value: email),
          const AppDivider(),
          _ProfileInfoTile(label: 'Registered Phone', value: phone),
          const AppDivider(),
          const _ProfileInfoTile(
            label: 'Authentication',
            value: 'Single Sign-On (University Active Directory)',
          ),
          const AppDivider(),
          const _ProfileInfoTile(
            label: 'Device Security',
            value: 'Authorized Mobile Session (Token Stored)',
          ),
        ],
      ),
    );
  }

  Widget _buildAppInfoCard() {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(
                      color: AppColors.border,
                      width: AppDimensions.strokeWidth,
                    ),
                  ),
                  padding: const EdgeInsets.all(6),
                  child: Image.asset(
                    'assets/images/logo.png',
                    fit: BoxFit.contain,
                  ),
                ),
                AppSpacing.hGap14,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Uni Secure',
                        style: AppTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.mainText,
                        ),
                      ),
                      AppSpacing.vGap2,
                      Text(
                        'NUML Campus Attendance & Security Edition',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const AppDivider(),
          const _ProfileInfoTile(
            label: 'Application Build',
            value: 'v1.0.0 (Production Build) - NUML Campus',
          ),
          const AppDivider(),
          const _ProfileInfoTile(
            label: 'Theme System',
            value: 'Material 3 Light Design System',
          ),
        ],
      ),
    );
  }
}

class _ProfileInfoTile extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileInfoTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.secondaryText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          AppSpacing.hGap8,
          Expanded(
            child: Text(
              value,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.mainText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
