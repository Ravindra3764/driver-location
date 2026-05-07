import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_typography.dart';
import '../../../data/models/driver_model.dart';

class DriverDetailsSheet extends StatelessWidget {
  const DriverDetailsSheet({
    required this.driver,
    super.key,
  });

  final DriverModel driver;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.spacingLg,
        AppDimensions.spacingMd,
        AppDimensions.spacingLg,
        AppDimensions.spacingLg,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusXl),
        ),
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
            Text(AppStrings.driverDetailsTitle,
                style: AppTypography.labelSmall),
            const SizedBox(height: AppDimensions.spacingSm),
            Row(
              children: [
                _Avatar(url: driver.avatarUrl, name: driver.name),
                const SizedBox(width: AppDimensions.spacingMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(driver.name, style: AppTypography.titleLarge),
                      const SizedBox(height: 2),
                      Text(
                        '${driver.vehicleType} · ${driver.vehicleNumber}',
                        style: AppTypography.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingLg),
            Row(
              children: [
                Expanded(
                  child: _StatTile(
                    icon: Icons.star_rounded,
                    iconColor: AppColors.warning,
                    label: AppStrings.ratingLabel,
                    value: driver.rating.toStringAsFixed(1),
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingMd),
                Expanded(
                  child: _StatTile(
                    icon: Icons.local_shipping_outlined,
                    iconColor: AppColors.primary,
                    label: AppStrings.tripsLabel,
                    value: '${driver.totalTrips}',
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingMd),
                Expanded(
                  child: _StatTile(
                    icon: Icons.two_wheeler_rounded,
                    iconColor: AppColors.accentDark,
                    label: AppStrings.vehicleLabel,
                    value: driver.vehicleType,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingLg),
            Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    icon: Icons.call_rounded,
                    label: AppStrings.callDriver,
                    primary: true,
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingMd),
                Expanded(
                  child: _ActionButton(
                    icon: Icons.chat_bubble_outline_rounded,
                    label: AppStrings.messageDriver,
                    primary: false,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.url, required this.name});

  final String url;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        shape: BoxShape.circle,
      ),
      child: ClipOval(
        child: Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => Container(
            color: AppColors.surfaceMuted,
            alignment: Alignment.center,
            child: Text(
              _initials(name),
              style: AppTypography.titleMedium,
            ),
          ),
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return (parts.first.characters.first + parts.last.characters.first)
        .toUpperCase();
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppDimensions.spacingMd,
        horizontal: AppDimensions.spacingSm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(height: AppDimensions.spacingXs),
          Text(value, style: AppTypography.titleMedium),
          Text(label, style: AppTypography.labelSmall),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.primary,
  });

  final IconData icon;
  final String label;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final Color bg = primary ? AppColors.primary : AppColors.surface;
    final Color fg = primary ? AppColors.surface : AppColors.primary;
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: AppDimensions.spacingMd,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            border: Border.all(
              color: primary ? AppColors.primary : AppColors.border,
            ),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: fg, size: 18),
              const SizedBox(width: AppDimensions.spacingSm),
              Text(
                label,
                style: AppTypography.button.copyWith(color: fg),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
