import 'package:fl_mhis_hr/library/constant.dart';
import 'package:flutter/material.dart';

class MessageState extends StatelessWidget {
  const MessageState({super.key, required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final hasRetry = onRetry != null;
    final accentColor =
        hasRetry ? const Color(0xFFD97745) : const Color(0xFF218D70);

    return Center(
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        elevation: 0,
        color: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFFE1E0DE)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  hasRetry
                      ? Icons.cloud_off_outlined
                      : Icons.event_available_outlined,
                  color: accentColor,
                  size: 32,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                hasRetry ? 'Something went wrong' : 'All caught up',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF292B30),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF737983),
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              if (hasRetry) ...[
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Retry'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.lightblue,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
