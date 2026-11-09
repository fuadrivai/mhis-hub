import 'package:fl_mhis_hr/library/common.dart';
import 'package:flutter/material.dart';

class GradientButtonBackground extends StatelessWidget {
  const GradientButtonBackground({
    super.key,
    required this.child,
    this.enabled = true,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
  });

  final Widget child;
  final bool enabled;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: enabled ? Common.redGradient : null,
        color: enabled ? null : Colors.grey.shade400,
        borderRadius: borderRadius,
      ),
      child: child,
    );
  }
}
