import 'package:fl_mhis_hr/library/constant.dart';
import 'package:fl_mhis_hr/models/v2/models.dart';
import 'package:fl_mhis_hr/widget/gradient_button_background.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CardClockInOut extends StatelessWidget {
  const CardClockInOut({super.key, required this.shift});
  final Shift? shift;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.danger.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.access_time_rounded,
                    color: AppColors.danger),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Schedule: ${shift?.name ?? 'WS'}",
                      style: const TextStyle(
                        color: AppColors.dark,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    if (shift != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        shift!.fullScheduleTime(),
                        style: const TextStyle(color: AppColors.blackshade),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _AttendanceButton(
                  label: 'Clock In',
                  icon: Icons.login_rounded,
                  onPressed: () => context.goNamed('clockin'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _AttendanceButton(
                  label: 'Clock Out',
                  icon: Icons.logout_rounded,
                  onPressed: () => context.goNamed('clockout'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AttendanceButton extends StatelessWidget {
  const _AttendanceButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => GradientButtonBackground(
        child: SizedBox(
          height: 48,
          child: FilledButton(
            onPressed: onPressed,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.white,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 18),
                  const SizedBox(width: 6),
                  Text(label),
                ],
              ),
            ),
          ),
        ),
      );
}
