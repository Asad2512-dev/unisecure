import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../data/models/student_models.dart';
import '../../controllers/student_controller.dart';

class StudentCampusHistoryView extends GetView<StudentController> {
  const StudentCampusHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(title: const Text('Campus Access Log')),
      body: Column(
        children: [
          // Filter Chips (All, Entry, Exit)
          Obx(() {
            final activeFilter = controller.selectedAccessFilter.value;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: AppColors.surface,
              child: Row(
                children: ['All', 'Entry', 'Exit'].map((filter) {
                  final isSelected = activeFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(filter),
                      selected: isSelected,
                      onSelected: (_) => controller.filterAccess(filter),
                      selectedColor: AppColors.primarySoft,
                      backgroundColor: AppColors.surfaceSubtle,
                      labelStyle: AppTypography.labelSmall.copyWith(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.secondaryText,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                      side: BorderSide(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.border,
                        width: AppDimensions.strokeWidth,
                      ),
                    ),
                  );
                }).toList(),
              ),
            );
          }),

          // Transactions List
          Expanded(
            child: Obx(() {
              final list = controller.filteredAccessHistory;

              if (list.isEmpty) {
                return const AppEmptyState(
                  icon: AppIcons.gate,
                  title: 'No access records found',
                  message:
                      'No gate entry or exit records match your current filter.',
                );
              }

              return RefreshIndicator(
                onRefresh: controller.refreshData,
                color: AppColors.primary,
                child: ListView.builder(
                  padding: AppSpacing.screen,
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final tx = list[index];
                    return _AccessTransactionCard(transaction: tx);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _AccessTransactionCard extends StatelessWidget {
  final AccessTransaction transaction;

  const _AccessTransactionCard({required this.transaction});

  String _formatTime(DateTime dt) {
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final day = dt.day.toString().padLeft(2, '0');
    return '${dt.year}-$month-$day  $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final isEntry = transaction.isEntry;
    final accentColor = isEntry ? AppColors.success : AppColors.warning;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Icon(
                    isEntry ? AppIcons.entry : AppIcons.exit,
                    color: accentColor,
                    size: AppDimensions.iconSm,
                  ),
                ),
                AppSpacing.hGap12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isEntry ? 'CAMPUS ENTRY' : 'CAMPUS EXIT',
                            style: AppTypography.labelSmall.copyWith(
                              color: accentColor,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                          AppStatusBadge(
                            label: transaction.status.toUpperCase(),
                            color: transaction.status == 'granted'
                                ? AppColors.success
                                : AppColors.error,
                          ),
                        ],
                      ),
                      AppSpacing.vGap2,
                      Text(
                        transaction.gateName,
                        style: AppTypography.titleSmall.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            AppSpacing.vGap12,
            const AppDivider(),
            AppSpacing.vGap8,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.fingerprint_rounded,
                      size: 14,
                      color: AppColors.secondaryText,
                    ),
                    AppSpacing.hGap4,
                    Text(
                      transaction.verificationMethod,
                      style: AppTypography.caption.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.mainText,
                      ),
                    ),
                  ],
                ),
                Text(
                  _formatTime(transaction.eventAt),
                  style: AppTypography.caption.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
            if (transaction.notes != null) ...[
              AppSpacing.vGap4,
              Text(
                transaction.notes!,
                style: AppTypography.caption.copyWith(
                  color: AppColors.secondaryText,
                  fontStyle: FontStyle.italic,
                  fontSize: 11,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
