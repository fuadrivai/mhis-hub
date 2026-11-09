import 'package:fl_mhis_hr/library/constant.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ThemedPage extends StatelessWidget {
  const ThemedPage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.onBack,
    this.backIcon = Icons.arrow_back,
    this.backTooltip = 'Back',
    this.actions = const [],
  });

  final String title;
  final String subtitle;
  final Widget child;
  final VoidCallback? onBack;
  final IconData backIcon;
  final String backTooltip;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FA),
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.paddingOf(context).top + 220,
            child: DecoratedBox(
              decoration: BoxDecoration(gradient: Common.homeHeaderGradient),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 18),
                  child: Row(
                    children: [
                      IconButton(
                        tooltip: backTooltip,
                        onPressed: onBack ?? () => context.pop(),
                        icon: Icon(backIcon, color: Colors.white),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(title,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700)),
                            const SizedBox(height: 4),
                            Text(subtitle,
                                style: const TextStyle(color: Colors.white)),
                          ],
                        ),
                      ),
                      ...actions,
                    ],
                  ),
                ),
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ThemedMessageCard extends StatelessWidget {
  const ThemedMessageCard({
    super.key,
    required this.message,
    required this.onRetry,
    this.details,
    this.buttonText = 'Refresh',
  });

  final String message;
  final String? details;
  final String buttonText;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.danger.withValues(alpha: 0.1)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.info_outline, color: AppColors.danger, size: 36),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          if (details != null && details!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(details!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey)),
          ],
          const SizedBox(height: 8),
          TextButton(
            onPressed: onRetry,
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }
}
