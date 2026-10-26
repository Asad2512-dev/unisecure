import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../data/models/guard_models.dart';
import '../../controllers/guard_visitor_controller.dart';

/// Detailed view of an active or departed visitor pass.
class GuardVisitorDetailView extends StatelessWidget {
  final Visitor visitor;

  const GuardVisitorDetailView({super.key, required this.visitor});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<GuardVisitorController>();

    return AppScaffold(
      appBar: AppBar(title: Text(visitor.badgeNumber)),
      body: ListView(
        padding: AppSpacing.screen,
        children: [
          // Pass Badge Card
          AppCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft,
                        borderRadius: BorderRadius.circular(AppRadius.xs),
                      ),
                      child: Text(
                        visitor.badgeNumber,
                        style: AppTypography.labelMedium.copyWith(
                          color: AppColors.primaryDark,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    AppStatusBadge(
                      label: visitor.isActive ? 'ON CAMPUS' : 'CHECKED OUT',
                      color: visitor.isActive
                          ? AppColors.success
                          : AppColors.secondaryText,
                    ),
                  ],
                ),
                AppSpacing.vGap16,
                Text(
                  visitor.name,
                  style: AppTypography.headlineMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                AppSpacing.vGap4,
                Text(
                  visitor.phone,
                  style: AppTypography.titleSmall.copyWith(
                    color: AppColors.secondaryText,
                    fontFamily: 'monospace',
                  ),
                ),
                AppSpacing.vGap16,
                const AppDivider(),
                AppSpacing.vGap12,
                _DetailRow(label: 'Purpose of Visit', value: visitor.purpose),
                _DetailRow(
                  label: 'Host / Dept',
                  value: visitor.hostDepartmentOrPerson,
                ),
                _DetailRow(
                  label: 'ID Proof Provided',
                  value: '${visitor.idProofType} (${visitor.idProofNumber})',
                ),
                if (visitor.vehicleNumber != null)
                  _DetailRow(
                    label: 'Vehicle Plate',
                    value: visitor.vehicleNumber!,
                  ),
                _DetailRow(
                  label: 'Gate Registered',
                  value: visitor.registeredByGate,
                ),
                _DetailRow(
                  label: 'Check-In Time',
                  value: visitor.checkInFormatted,
                ),
                if (visitor.checkOutFormatted != null)
                  _DetailRow(
                    label: 'Check-Out Time',
                    value: visitor.checkOutFormatted!,
                  ),
              ],
            ),
          ),
          AppSpacing.vGap24,

          // Actions
          if (visitor.isActive)
            AppButton.primary(
              text: 'Check Out Visitor',
              icon: Icons.logout_rounded,
              onPressed: () async {
                await controller.checkoutVisitor(
                  context: context,
                  visitor: visitor,
                );
                Get.back();
              },
            )
          else
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceSubtle,
                borderRadius: BorderRadius.circular(AppRadius.card),
                border: Border.all(color: AppColors.border),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: AppColors.secondaryText,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Visitor has departed campus. Pass closed.',
                    style: TextStyle(color: AppColors.secondaryText),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: AppColors.secondaryText,
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: AppTypography.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.mainText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
