import 'package:fl_mhis_hr/library/constant.dart';
import 'package:fl_mhis_hr/models/v2/announcement.dart';
import 'package:fl_mhis_hr/pages/general_announcement/bloc/general_announcement_bloc.dart';
import 'package:fl_mhis_hr/pages/general_announcement/screen/announcement_layout.dart';
import 'package:fl_mhis_hr/service/api.dart';
import 'package:fl_mhis_hr/widget/widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:jiffy/jiffy.dart';

class GeneralAnnouncementScreen extends StatefulWidget {
  const GeneralAnnouncementScreen({super.key});

  @override
  State<GeneralAnnouncementScreen> createState() =>
      _GeneralAnnouncementScreenState();
}

class _GeneralAnnouncementScreenState extends State<GeneralAnnouncementScreen> {
  String _creatorName(Announcement announcement) {
    final String? personalName = announcement.creator?.personal?.fullname;
    if (personalName != null && personalName.trim().isNotEmpty) {
      return personalName.trim();
    }

    final String? userName = announcement.creator?.user?.name;
    if (userName != null && userName.trim().isNotEmpty) {
      return userName.trim();
    }

    return 'Unknown creator';
  }

  String _creatorInitials(String name) {
    final List<String> parts =
        name.split(RegExp(r'\s+')).where((item) => item.isNotEmpty).toList();
    if (parts.isEmpty) {
      return 'U';
    }

    return parts.take(2).map((part) => part[0]).join().toUpperCase();
  }

  String? _avatarUrl(Announcement announcement) {
    final String? avatar = announcement.creator?.personal?.avatar;
    if (avatar == null || avatar.trim().isEmpty) {
      return null;
    }

    if (avatar.startsWith('http://') || avatar.startsWith('https://')) {
      return avatar;
    }

    return '${Api.url}/storage/$avatar';
  }

  String _publishDateLabel(Announcement announcement) {
    final String? rawDate = announcement.publishAt;
    if (rawDate == null || rawDate.trim().isEmpty) {
      return '-';
    }

    try {
      return Jiffy.parse(rawDate).format(pattern: 'dd MMM yyyy');
    } catch (_) {
      return rawDate;
    }
  }

  @override
  void initState() {
    context.read<GeneralAnnouncementBloc>().add(const OnInit());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnnouncementLayout(
      subtitle: 'Stay up to date with the latest news',
      child: BlocBuilder<GeneralAnnouncementBloc, GeneralAnnouncementState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const LoadingWidget();
          }
          return RefreshIndicator(
            color: AppColors.danger,
            onRefresh: () async {
              context.read<GeneralAnnouncementBloc>().add(const OnInit());
            },
            child: (state.announcements ?? []).isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.campaign_outlined,
                                size: 40, color: AppColors.danger),
                            const SizedBox(height: 12),
                            const Text('No announcements found'),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: () => context
                                  .read<GeneralAnnouncementBloc>()
                                  .add(const OnInit()),
                              style: TextButton.styleFrom(
                                  foregroundColor: AppColors.danger),
                              child: const Text('Refresh'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemBuilder: (context, i) {
                      final Announcement ann = (state.announcements ?? [])[i];
                      final String creatorName = _creatorName(ann);
                      final String creatorInitials =
                          _creatorInitials(creatorName);
                      final String? avatarUrl = _avatarUrl(ann);
                      final String publishDate = _publishDateLabel(ann);

                      return Material(
                        color: AppColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: AppColors.danger.withValues(alpha: 0.1),
                          ),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () {
                            context.goNamed("general-announcement-view",
                                extra: {"announcement": ann});
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 22,
                                  backgroundColor: AppColors.danger.withValues(
                                    alpha: 0.12,
                                  ),
                                  child: ClipOval(
                                    child: avatarUrl == null
                                        ? Text(
                                            creatorInitials,
                                            style: const TextStyle(
                                              color: AppColors.danger,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 13,
                                            ),
                                          )
                                        : Image.network(
                                            avatarUrl,
                                            width: 44,
                                            height: 44,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stack) {
                                              return Text(
                                                creatorInitials,
                                                style: const TextStyle(
                                                  color: AppColors.danger,
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 13,
                                                ),
                                              );
                                            },
                                          ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        ann.title ?? 'Untitled announcement',
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        creatorName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              color: Colors.black87,
                                              fontWeight: FontWeight.w500,
                                            ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        publishDate,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: Colors.black54,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.chevron_right_rounded,
                                  color: AppColors.danger,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    itemCount: (state.announcements ?? []).length,
                    separatorBuilder: (context, index) {
                      return const SizedBox(height: 10);
                    },
                  ),
          );
        },
      ),
    );
  }
}
