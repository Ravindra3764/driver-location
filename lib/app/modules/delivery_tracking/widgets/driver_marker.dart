import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../data/models/driver_model.dart';

/// A pin-style marker that shows the driver's profile picture inside a
/// circular avatar, with a teardrop tail underneath. Tapping the marker
/// invokes [onTap].
class DriverMarker extends StatelessWidget {
  const DriverMarker({
    required this.driver,
    required this.onTap,
    this.isOffline = false,
    super.key,
  });

  final DriverModel driver;
  final VoidCallback onTap;
  final bool isOffline;

  @override
  Widget build(BuildContext context) {
    final Color ringColor =
        isOffline ? AppColors.textTertiary : AppColors.primary;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: AppDimensions.markerSize,
        height: AppDimensions.markerSize + 8,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            // Pulse halo (only when live).
            if (!isOffline)
              Positioned(
                top: 4,
                child: _PulseHalo(color: ringColor),
              ),
            // Teardrop tail.
            Positioned(
              bottom: 0,
              child: CustomPaint(
                size: const Size(14, 12),
                painter: _PinTailPainter(color: ringColor),
              ),
            ),
            // Avatar inside coloured ring.
            Positioned(
              top: 2,
              child: Container(
                width: AppDimensions.markerAvatarSize,
                height: AppDimensions.markerAvatarSize,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: ringColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.18),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.network(
                    driver.avatarUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      color: AppColors.surfaceMuted,
                      alignment: Alignment.center,
                      child: Text(
                        _initials(driver.name),
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return Container(
                        color: AppColors.surfaceMuted,
                        alignment: Alignment.center,
                        child: const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return (parts.first.characters.first + parts.last.characters.first)
        .toUpperCase();
  }
}

class _PinTailPainter extends CustomPainter {
  _PinTailPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..color = color;
    final Path path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _PinTailPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _PulseHalo extends StatefulWidget {
  const _PulseHalo({required this.color});

  final Color color;

  @override
  State<_PulseHalo> createState() => _PulseHaloState();
}

class _PulseHaloState extends State<_PulseHalo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, _) {
        final double t = _controller.value;
        final double size = AppDimensions.markerAvatarSize + 18 * t;
        final double opacity = (1 - t).clamp(0.0, 1.0) * 0.35;
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color.withValues(alpha: opacity),
          ),
        );
      },
    );
  }
}
