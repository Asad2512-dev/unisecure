import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../data/models/guard_models.dart';
import '../../controllers/guard_visitor_controller.dart';
import '../visitors/guard_register_visitor_view.dart';
import '../visitors/guard_visitor_detail_view.dart';

/// Screen managing on-campus visitors, registration shortcuts, and departures.
class GuardVisitorsTab extends StatelessWidget {
  const GuardVisitorsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(GuardVisitorController());

    return Column(
      children: [
        // Filter & Search Header
        Container(
          color: AppColors.surface,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: AppSearchField(
                      hint: 'Search visitor, host, badge...',
                      onChanged: controller.searchVisitors,
                    ),
                  ),
                  AppSpacing.hGap10,
                  AppButton.primary(
                    text: 'Register',
                    icon: Icons.person_add_rounded,
                    height: 44,
                    isFullWidth: false,
                    onPressed: () =>
                        Get.to(() => const GuardRegisterVisitorView()),
                  ),
                ],
              ),
              AppSpacing.vGap10,

              // Status Filter Chips
              Obx(() {
                final current = controller.selectedStatusFilter.value;
                final options = [
                  {'label': 'All Visitors', 'value': 'All'},
                  {'label': 'Active on Campus', 'value': 'active'},
                  {'label': 'Checked Out', 'value': 'checked_out'},
                ];

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: options.map((opt) {
                      final isSelected = current == opt['value'];
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(opt['label']!),
                          selected: isSelected,
                          onSelected: (_) =>
                              controller.filterStatus(opt['value']!),
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
            ],
          ),
        ),
        const AppDivider(),

        // Visitors List
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const AppLoading(message: 'Loading visitor passes...');
            }

            final visitors = controller.visitors;

            if (visitors.isEmpty) {
              return const AppEmptyState(
                icon: Icons.group_off_rounded,
                title: 'No Visitors Found',
                message:
                    'No visitor records match your active search or status filter.',
              );
            }

            return RefreshIndicator(
              onRefresh: controller.loadVisitors,
              color: AppColors.primary,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                itemCount: visitors.length,
                itemBuilder: (context, index) {
                  final visitor = visitors[index];
                  return _VisitorCard(
                    visitor: visitor,
                    onTap: () =>
                        Get.to(() => GuardVisitorDetailView(visitor: visitor)),
                    onCheckOut: visitor.isActive
                        ? () => controller.checkoutVisitor(
                            context: context,
                            visitor: visitor,
                          )
                        : null,
                  );
                },
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _VisitorCard extends StatelessWidget {
  final Visitor visitor;
  final VoidCallback onTap;
  final VoidCallback? onCheckOut;

  const _VisitorCard({
    required this.visitor,
    required this.onTap,
    this.onCheckOut,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        onTap: onTap,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(AppRadius.xs),
                  ),
                  child: Text(
                    visitor.badgeNumber,
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                AppStatusBadge(
                  label: visitor.isActive ? 'ON CAMPUS' : 'DEPARTED',
                  color: visitor.isActive
                      ? AppColors.success
                      : AppColors.secondaryText,
                ),
              ],
            ),
            AppSpacing.vGap10,
            Text(
              visitor.name,
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            AppSpacing.vGap4,
            Text(
              '${visitor.phone}  •  Host: ${visitor.hostDepartmentOrPerson}',
              style: AppTypography.caption.copyWith(
                color: AppColors.secondaryText,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            AppSpacing.vGap6,
            Text(
              'Purpose: ${visitor.purpose}',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.mainText,
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
                Text(
                  'Checked in at ${visitor.checkInFormatted}',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
                if (visitor.isActive && onCheckOut != null)
                  AppButton.outlined(
                    text: 'Check Out',
                    height: 34,
                    isFullWidth: false,
                    icon: Icons.logout_rounded,
                    onPressed: onCheckOut,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
