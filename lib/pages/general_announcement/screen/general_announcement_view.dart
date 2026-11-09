import 'package:fl_mhis_hr/library/constant.dart';
import 'package:fl_mhis_hr/models/v2/models.dart';
import 'package:fl_mhis_hr/pages/general_announcement/screen/announcement_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:jiffy/jiffy.dart';

class GeneralAnnouncementView extends StatelessWidget {
  const GeneralAnnouncementView({super.key, required this.announcement});

  final Announcement announcement;

  @override
  Widget build(BuildContext context) {
    final recipients = announcement.allEmployees == true
        ? <String>['All Employees']
        : <String>[
            ...?announcement.branches?.map((item) => item.name ?? '--'),
            ...?announcement.organizations?.map((item) => item.name ?? '--'),
            ...?announcement.positions?.map((item) => item.name ?? '--'),
            ...?announcement.jobLevels?.map((item) => item.name ?? '--'),
          ];
    final creator = announcement.creator?.personal?.fullname?.trim();
    final userName = announcement.creator?.user?.name?.trim();
    final creatorName = creator != null && creator.isNotEmpty
        ? creator
        : (userName != null && userName.isNotEmpty
            ? userName
            : 'Unknown creator');
    final rawDate = announcement.publishAt;
    final date = rawDate == null ? null : DateTime.tryParse(rawDate);
    final dateLabel = date == null
        ? (rawDate == null || rawDate.trim().isEmpty ? '-' : rawDate)
        : Jiffy.parseFromDateTime(date).format(pattern: 'dd MMM yyyy');

    return AnnouncementLayout(
      subtitle: 'Announcement details',
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.danger.withValues(alpha: 0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.danger.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  announcement.category?.name ?? 'Uncategorized',
                  style: const TextStyle(
                    color: AppColors.danger,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                announcement.title ?? '',
                style: const TextStyle(
                  color: AppColors.dark,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              _DetailLine(
                  icon: Icons.person_outline, text: 'From $creatorName'),
              const SizedBox(height: 8),
              _DetailLine(
                icon: Icons.calendar_today_outlined,
                text: 'Post on : $dateLabel',
              ),
              const SizedBox(height: 12),
              const Text(
                'Post To :',
                style: TextStyle(
                  color: AppColors.dark,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: recipients
                    .map(
                      (recipient) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.danger.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          recipient,
                          style: const TextStyle(color: AppColors.danger),
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Html(
                data: announcement.content ?? '',
                onLinkTap: (url, attributes, element) async {
                  if (url == null || url.isEmpty) return;
                  await Common.launchExternalUrl(url);
                },
              ),
              if (announcement.link != null &&
                  announcement.link!.isNotEmpty) ...[
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: () => Common.launchExternalUrl(announcement.link!),
                  icon: const Icon(Icons.link, size: 20),
                  label: const Text('Link'),
                  style:
                      TextButton.styleFrom(foregroundColor: AppColors.danger),
                ),
              ],
              if (announcement.attachment != null &&
                  announcement.attachment!.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Attachment',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    announcement.attachmentLink(),
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text('Unable to load attachment'),
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

class _DetailLine extends StatelessWidget {
  const _DetailLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.danger),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text, style: const TextStyle(color: Colors.black87)),
        ),
      ],
    );
  }
}
