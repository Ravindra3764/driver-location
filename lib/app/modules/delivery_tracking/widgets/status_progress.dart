import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/enums/delivery_status.dart';

class StatusProgress extends StatelessWidget {
  const StatusProgress({required this.current, super.key});

  final DeliveryStatus current;

  @override
  Widget build(BuildContext context) {
    final List<DeliveryStatus> steps = DeliveryStatus.values;
    return Row(
      children: List.generate(steps.length * 2 - 1, (index) {
        if (index.isOdd) {
          final int prevStep = (index - 1) ~/ 2;
          final bool active = current.step > prevStep;
          return Expanded(
            child: Container(
              height: 2,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              color: active ? AppColors.statusComplete : AppColors.divider,
            ),
          );
        }

        final int stepIndex = index ~/ 2;
        final DeliveryStatus step = steps[stepIndex];
        // Once the lifecycle reaches its terminal state, that final step
        // should also render as completed (green + check), not as the
        // active "current" dot.
        final bool isComplete =
            current.step > stepIndex ||
            (current.isTerminal && current.step == stepIndex);
        final bool isCurrent = !isComplete && current.step == stepIndex;
        return _StepDot(
          label: step.label,
          isComplete: isComplete,
          isCurrent: isCurrent,
        );
      }),
    );
  }
}

class _StepDot extends StatelessWidget {
  const _StepDot({
    required this.label,
    required this.isComplete,
    required this.isCurrent,
  });

  final String label;
  final bool isComplete;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    final Color color = isComplete
        ? AppColors.statusComplete
        : isCurrent
        ? AppColors.statusActive
        : AppColors.statusPending;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: isCurrent ? AppColors.surface : color,
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
          alignment: Alignment.center,
          child: isComplete
              ? const Icon(
                  Icons.check_rounded,
                  size: 14,
                  color: AppColors.surface,
                )
              : Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isCurrent ? color : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                ),
        ),
        const SizedBox(height: AppDimensions.spacingXs),
        SizedBox(
          width: 64,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTypography.bodySmall.copyWith(
              color: isComplete || isCurrent
                  ? AppColors.textPrimary
                  : AppColors.textTertiary,
              fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}
