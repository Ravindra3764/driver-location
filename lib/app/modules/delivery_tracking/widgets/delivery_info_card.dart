import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/enums/delivery_status.dart';
import '../controllers/delivery_tracking_controller.dart';
import 'status_progress.dart';

class DeliveryInfoCard extends GetView<DeliveryTrackingController> {
  const DeliveryInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingLg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusXl),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: AppDimensions.sheetHandleWidth,
                height: AppDimensions.sheetHandleHeight,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusPill,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.spacingLg),
            Obx(() {
              final DeliveryStatus status = controller.status;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _StatusBadge(status: status),
                      const Spacer(),
                      Text(
                        '#${controller.delivery.value.orderId}',
                        style: AppTypography.labelSmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.spacingSm),
                  Text(status.hint, style: AppTypography.titleMedium),
                ],
              );
            }),
            const SizedBox(height: AppDimensions.spacingLg),
            Obx(() => StatusProgress(current: controller.status)),
            const SizedBox(height: AppDimensions.spacingLg),
            const Divider(height: 1),
            const SizedBox(height: AppDimensions.spacingLg),
            Obx(() {
              final hasDriver = controller.driver != null;
              return Row(
                children: [
                  Expanded(
                    child: _MetricTile(
                      icon: Icons.timer_outlined,
                      label: AppStrings.etaLabel,
                      value: hasDriver ? controller.etaLabel : '--',
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spacingMd),
                  Expanded(
                    child: _MetricTile(
                      icon: Icons.route_outlined,
                      label: AppStrings.distanceLabel,
                      value: hasDriver ? controller.distanceLabel : '--',
                    ),
                  ),
                ],
              );
            }),
            const SizedBox(height: AppDimensions.spacingMd),
            const _DropAddressRow(),
            const SizedBox(height: AppDimensions.spacingMd),
            Obx(() {
              if (controller.driver == null) {
                return const _SearchingHint();
              }
              return Text(
                AppStrings.tapMarkerHint,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textTertiary,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final DeliveryStatus status;

  @override
  Widget build(BuildContext context) {
    final Color color = status.isTerminal
        ? AppColors.statusComplete
        : AppColors.statusActive;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingMd,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            status.label,
            style: AppTypography.labelLarge.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingMd),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: AppDimensions.spacingSm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label, style: AppTypography.labelSmall),
              Text(value, style: AppTypography.titleMedium),
            ],
          ),
        ],
      ),
    );
  }
}

class _DropAddressRow extends GetView<DeliveryTrackingController> {
  const _DropAddressRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          ),
          alignment: Alignment.center,
          child: const Icon(
            Icons.location_on_outlined,
            color: AppColors.accentDark,
            size: 18,
          ),
        ),
        const SizedBox(width: AppDimensions.spacingMd),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Drop-off', style: AppTypography.labelSmall),
              Text(
                controller.delivery.value.dropAddress,
                style: AppTypography.bodyLarge,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SearchingHint extends StatelessWidget {
  const _SearchingHint();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(
          width: 14,
          height: 14,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        const SizedBox(width: AppDimensions.spacingSm),
        Text(
          'Finding the closest delivery partner...',
          style: AppTypography.bodySmall,
        ),
      ],
    );
  }
}
