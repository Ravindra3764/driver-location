import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_typography.dart';
import '../controllers/delivery_tracking_controller.dart';
import '../widgets/delivery_info_card.dart';
import '../widgets/destination_marker.dart';
import '../widgets/driver_details_sheet.dart';
import '../widgets/driver_marker.dart';
import '../widgets/network_banner.dart';

class DeliveryTrackingView extends GetView<DeliveryTrackingController> {
  const DeliveryTrackingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const _MapLayer(),
          const _TopOverlay(),
          Positioned(
            right: AppDimensions.spacingLg,
            bottom: 360,
            child: _MapControls(),
          ),
          const Align(
            alignment: Alignment.bottomCenter,
            child: DeliveryInfoCard(),
          ),
          _DriverDetailsLayer(),
        ],
      ),
    );
  }
}

class _MapLayer extends GetView<DeliveryTrackingController> {
  const _MapLayer();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final LatLng center = controller.displayedDriverLocation ??
          controller.delivery.value.dropLocation;

      return FlutterMap(
        mapController: controller.mapController,
        options: MapOptions(
          initialCenter: center,
          initialZoom: AppDimensions.mapInitialZoom,
          minZoom: AppDimensions.mapMinZoom,
          maxZoom: AppDimensions.mapMaxZoom,
          interactionOptions: const InteractionOptions(
            flags: InteractiveFlag.drag |
                InteractiveFlag.pinchZoom |
                InteractiveFlag.doubleTapZoom |
                InteractiveFlag.flingAnimation,
          ),
        ),
        children: [
          TileLayer(
            urlTemplate:
                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.driver_location',
            maxZoom: 19,
          ),
          const _RouteLine(),
          const _MarkersLayer(),
        ],
      );
    });
  }
}

class _RouteLine extends GetView<DeliveryTrackingController> {
  const _RouteLine();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final LatLng? driverPos = controller.displayedDriverLocation;
      if (driverPos == null) return const SizedBox.shrink();
      return PolylineLayer(
        polylines: [
          Polyline(
            points: [driverPos, controller.delivery.value.dropLocation],
            color: controller.isOffline
                ? AppColors.textTertiary
                : AppColors.primary,
            strokeWidth: 4,
            pattern: controller.isOffline
                ? const StrokePattern.dotted()
                : const StrokePattern.solid(),
          ),
        ],
      );
    });
  }
}

class _MarkersLayer extends GetView<DeliveryTrackingController> {
  const _MarkersLayer();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final markers = <Marker>[
        Marker(
          point: controller.delivery.value.dropLocation,
          width: 36,
          height: 36,
          alignment: Alignment.center,
          child: const DestinationMarker(),
        ),
      ];

      final LatLng? driverPos = controller.displayedDriverLocation;
      final driver = controller.driver;
      if (driverPos != null && driver != null) {
        markers.add(
          Marker(
            point: driverPos,
            width: AppDimensions.markerSize,
            height: AppDimensions.markerSize + 8,
            alignment: Alignment.topCenter,
            child: DriverMarker(
              driver: driver,
              isOffline: controller.isOffline,
              onTap: controller.openDriverDetails,
            ),
          ),
        );
      }
      return MarkerLayer(markers: markers);
    });
  }
}

class _TopOverlay extends GetView<DeliveryTrackingController> {
  const _TopOverlay();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacingLg,
              vertical: AppDimensions.spacingMd,
            ),
            child: Row(
              children: [
                _CircleIconButton(
                  icon: Icons.arrow_back_rounded,
                  onTap: () {},
                ),
                const SizedBox(width: AppDimensions.spacingMd),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.spacingLg,
                      vertical: AppDimensions.spacingMd,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusPill,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.local_shipping_rounded,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: AppDimensions.spacingSm),
                        Flexible(
                          child: Text(
                            AppStrings.trackingTitle,
                            style: AppTypography.titleMedium,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingSm),
                _CircleIconButton(
                  icon: Icons.refresh_rounded,
                  tooltip: 'Restart tracking',
                  onTap: controller.restartTracking,
                ),
                const SizedBox(width: AppDimensions.spacingSm),
                _CircleIconButton(
                  icon: Icons.cloud_off_rounded,
                  tooltip: 'Toggle offline (demo)',
                  onTap: controller.toggleSimulatedNetwork,
                ),
              ],
            ),
          ),
          const NetworkBanner(),
        ],
      ),
    );
  }
}

class _MapControls extends GetView<DeliveryTrackingController> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _CircleIconButton(
          icon: Icons.my_location_rounded,
          tooltip: 'Recenter',
          onTap: controller.recenterMap,
        ),
      ],
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    required this.onTap,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final button = Material(
      color: AppColors.surface,
      shape: const CircleBorder(),
      elevation: 0,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.border),
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: 20, color: AppColors.textPrimary),
        ),
      ),
    );
    if (tooltip == null) return button;
    return Tooltip(message: tooltip!, child: button);
  }
}

class _DriverDetailsLayer extends GetView<DeliveryTrackingController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bool open = controller.isDriverDetailsOpen.value;
      final driver = controller.driver;
      if (!open || driver == null) return const SizedBox.shrink();
      return Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: controller.closeDriverDetails,
              child: Container(color: Colors.black.withValues(alpha: 0.35)),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: AnimatedSlide(
              duration: const Duration(milliseconds: 220),
              offset: open ? Offset.zero : const Offset(0, 1),
              child: DriverDetailsSheet(driver: driver),
            ),
          ),
        ],
      );
    });
  }
}
