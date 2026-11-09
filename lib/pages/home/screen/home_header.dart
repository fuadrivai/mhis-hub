import 'package:fl_mhis_hr/library/constant.dart';
import 'package:fl_mhis_hr/service/api.dart';
import 'package:flutter/material.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.name,
    required this.avatar,
    required this.hour,
    this.profileError = false,
  });

  final String? name;
  final String? avatar;
  final int hour;
  final bool profileError;

  String get _greeting {
    if (hour < 12) return 'Good Morning';
    if (hour < 15) return 'Good Afternoon';
    if (hour < 18) return 'Good Evening';
    return 'Good Night';
  }

  @override
  Widget build(BuildContext context) {
    final trimmedName = name?.trim();
    final avatarPath = avatar?.trim();
    final imageUrl = avatarPath == null || avatarPath.isEmpty
        ? null
        : avatarPath.startsWith('http://') || avatarPath.startsWith('https://')
            ? avatarPath
            : '${Api.url}/storage/$avatarPath';
    return Row(
      children: [
        Tooltip(
          message:
              profileError ? 'Unable to load profile photo' : 'Profile photo',
          child: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: ClipOval(
              child: imageUrl == null
                  ? const Icon(Icons.person, color: AppColors.danger)
                  : Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.person,
                        color: AppColors.danger,
                        semanticLabel: 'Unable to load profile photo',
                      ),
                    ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _greeting,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              if (trimmedName != null && trimmedName.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  trimmedName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
