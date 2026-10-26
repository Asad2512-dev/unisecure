import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../data/models/guard_models.dart';
import '../../controllers/guard_controller.dart';

/// Comprehensive campus access audit log screen with multi-facet filters.
class GuardHistoryTab extends GetView<GuardController> {
  const GuardHistoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Filter Controls Header
        Container(
          color: AppColors.surface,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
          child: Column(
            children: [
              AppSearchField(
                hint: 'Search by name, ID, gate, or audit note...',
                onChanged: controller.searchHistory,
              ),
              AppSpacing.vGap10,

              // Direction & Subject Filters
              Row(
                children: [
                  // Event Type (All, Entry, Exit)
                  Expanded(
                    child: Obx(() {
                      final current = controller.selectedEventFilter.value;
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: ['All', 'Entry', 'Exit'].map((type) {
                            final isSelected =
                                current.toLowerCase() == type.toLowerCase();
                            return Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: ChoiceChip(
                                label: Text(type),
                                selected: isSelected,
                                onSelected: (_) =>
                                    controller.filterHistoryEvent(type),
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
                  ),

                  // Subject Type (All, Student, Visitor)
                  Obx(() {
                    final current = controller.selectedSubjectFilter.value;
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _SubjectFilterPill(
                          label: 'Students',
                          value: 'student',
                          isSelected: current.toLowerCase() == 'student',
                          onTap: () => controller.filterHistorySubject(
                            current.toLowerCase() == 'student'
                                ? 'All'
                                : 'student',
                          ),
                        ),
                        AppSpacing.hGap6,
                        _SubjectFilterPill(
                          label: 'Visitors',
                          value: 'visitor',
                          isSelected: current.toLowerCase() == 'visitor',
                          onTap: () => controller.filterHistorySubject(
                            current.toLowerCase() == 'visitor'
                                ? 'All'
                                : 'visitor',
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ],
          ),
        ),
        const AppDivider(),

        // Transaction History List
        Expanded(
          child: Obx(() {
            final transactions = controller.allTransactions;

            if (transactions.isEmpty) {
              return const AppEmptyState(
                icon: Icons.history_rounded,
                title: 'No Access Logs Found',
                message:
                    'No perimeter transactions match the selected event direction, subject type, or search query.',
              );
            }

            return RefreshIndicator(
              onRefresh: controller.loadHistory,
              color: AppColors.primary,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                itemCount: transactions.length,
                itemBuilder: (context, index) {
                  final tx = transactions[index];
                  return _HistoryTransactionCard(transaction: tx);
                },
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _SubjectFilterPill extends StatelessWidget {
  final String label;
  final String value;
  final bool isSelected;
  final VoidCallback onTap;

  const _SubjectFilterPill({
    required this.label,
    required this.value,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.xs),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceSubtle,
          borderRadius: BorderRadius.circular(AppRadius.xs),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.caption.copyWith(
            color: isSelected ? Colors.white : AppColors.secondaryText,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _HistoryTransactionCard extends StatelessWidget {
  final GateTransaction transaction;

  const _HistoryTransactionCard({required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: transaction.isEntry
                            ? AppColors.successSoft
                            : AppColors.infoSoft,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        transaction.isEntry
                            ? Icons.login_rounded
                            : Icons.logout_rounded,
                        color: transaction.isEntry
                            ? AppColors.success
                            : AppColors.info,
                        size: 16,
                      ),
                    ),
                    AppSpacing.hGap8,
                    Text(
                      '${transaction.eventType.toUpperCase()} • ${transaction.gate}',
                      style: AppTypography.labelSmall.copyWith(
                        color: transaction.isEntry
                            ? AppColors.success
                            : AppColors.info,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${transaction.dateFormatted} (${transaction.timeFormatted})',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.secondaryText,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
            AppSpacing.vGap12,
            Text(
              transaction.subjectName,
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            AppSpacing.vGap2,
            Text(
              '${transaction.subjectType.toUpperCase()}  •  ID: ${transaction.subjectIdentifier}  •  ${transaction.departmentOrProgram}',
              style: AppTypography.caption.copyWith(
                color: AppColors.secondaryText,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            AppSpacing.vGap12,
            const AppDivider(),
            AppSpacing.vGap10,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSubtle,
                    borderRadius: BorderRadius.circular(AppRadius.xs),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    transaction.methodDisplayName,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.mainText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Flexible(
                  child: Text(
                    'Audit by ${transaction.verifiedByGuardName}',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.secondaryText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            if (transaction.notes != null && transaction.notes!.isNotEmpty) ...[
              AppSpacing.vGap8,
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSubtle,
                  borderRadius: BorderRadius.circular(AppRadius.xs),
                ),
                child: Text(
                  'Note: ${transaction.notes}',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.secondaryText,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
