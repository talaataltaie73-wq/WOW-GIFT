import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class CheckoutProgressIndicator extends StatelessWidget {
  final int activeStep;

  const CheckoutProgressIndicator({
    super.key,
    required this.activeStep,
  });

  static const List<String> _stepLabels = [
    'المعلومات',
    'رقم الجوال',
    'وسيلة الدفع',
    'تأكيد الطلب',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(
          bottom: BorderSide(
            color: AppColors.border.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: List.generate(4, (index) {
          final stepNumber = index + 1;
          final isActive = stepNumber == activeStep;
          final isCompleted = stepNumber < activeStep;
          final isLast = index == 3;

          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildStepCircle(
                        stepNumber: stepNumber,
                        isActive: isActive,
                        isCompleted: isCompleted,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _stepLabels[index],
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                          color: isActive
                              ? AppColors.primary
                              : isCompleted
                                  ? AppColors.accent
                                  : AppColors.textHint,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: SizedBox(
                      width: 24,
                      child: Divider(
                        color: isCompleted
                            ? AppColors.accent
                            : AppColors.border,
                        thickness: isCompleted ? 2 : 1,
                      ),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStepCircle({
    required int stepNumber,
    required bool isActive,
    required bool isCompleted,
  }) {
    if (isCompleted) {
      return Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.accent, width: 2),
          color: AppColors.background,
        ),
        child: const Icon(
          Icons.check_rounded,
          size: 18,
          color: AppColors.accent,
        ),
      );
    }

    if (isActive) {
      return Container(
        width: 36,
        height: 36,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primary,
        ),
        child: Center(
          child: Text(
            '$stepNumber',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textOnPrimary,
            ),
          ),
        ),
      );
    }

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.border, width: 1.5),
        color: AppColors.background,
      ),
      child: Center(
        child: Text(
          '$stepNumber',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textHint,
          ),
        ),
      ),
    );
  }
}
