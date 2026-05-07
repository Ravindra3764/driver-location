import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_typography.dart';
import '../controllers/delivery_tracking_controller.dart';

class NetworkBanner extends GetView<DeliveryTrackingController> {
  const NetworkBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bool offline = controller.isOffline;
      final bool reconnected = controller.justReconnected.value;

      if (!offline && !reconnected) return const SizedBox.shrink();

      final bool isReconnect = !offline && reconnected;
      final Color bg =
          isReconnect ? AppColors.primaryLight : AppColors.offlineBanner;
      final Color fg =
          isReconnect ? AppColors.primaryDark : AppColors.offlineText;
      final IconData icon =
          isReconnect ? Icons.cloud_done_rounded : Icons.cloud_off_rounded;
      final String title =
          isReconnect ? AppStrings.reconnectingMessage : AppStrings.offlineTitle;
      final String? subtitle = isReconnect ? null : AppStrings.offlineMessage;

      return AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        margin: const EdgeInsets.fromLTRB(
          AppDimensions.spacingLg,
          AppDimensions.spacingMd,
          AppDimensions.spacingLg,
          0,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingLg,
          vertical: AppDimensions.spacingMd,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
        child: Row(
          children: [
            Icon(icon, color: fg, size: 22),
            const SizedBox(width: AppDimensions.spacingMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: AppTypography.titleMedium.copyWith(color: fg),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTypography.bodySmall.copyWith(color: fg),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}
