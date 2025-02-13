import 'package:fl_mhis_hr/library/constant.dart';
import 'package:fl_mhis_hr/models/model.dart';
import 'package:fl_mhis_hr/pages/general_announcement/bloc/general_announcement_bloc.dart';
import 'package:fl_mhis_hr/widget/widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:jiffy/jiffy.dart';

class GeneralAnnouncementScreen extends StatefulWidget {
  const GeneralAnnouncementScreen({super.key});

  @override
  State<GeneralAnnouncementScreen> createState() =>
      _GeneralAnnouncementScreenState();
}

class _GeneralAnnouncementScreenState extends State<GeneralAnnouncementScreen> {
  @override
  void initState() {
    context.read<GeneralAnnouncementBloc>().add(const OnInit());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        backgroundColor: AppColors.whiteshade,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back),
        ),
        actions: IconButton(
          onPressed: () => context.goNamed("general-announcement-form"),
          icon: const FaIcon(FontAwesomeIcons.plus),
        ),
        title: "Announcement",
      ),
      body: BlocBuilder<GeneralAnnouncementBloc, GeneralAnnouncementState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const LoadingWidget();
          }
          return RefreshIndicator(
            onRefresh: () async {
              context.read<GeneralAnnouncementBloc>().add(const OnInit());
            },
            child: Container(
              decoration: const BoxDecoration(color: AppColors.white),
              child: (state.announcements ?? []).isEmpty
                  ? EmptyWidget(
                      onTap: () {
                        context
                            .read<GeneralAnnouncementBloc>()
                            .add(const OnInit());
                      },
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      itemBuilder: (context, i) {
                        Announcement ann = (state.announcements ?? [])[i];
                        return ListTile(
                          leading: const Icon(FontAwesomeIcons.bellConcierge),
                          title: Text(ann.subject ?? ""),
                          subtitle: Text(Jiffy.parse(ann.date!)
                              .format(pattern: "dd MMMM yyyy")),
                          onTap: () {
                            context.goNamed("general-announcement-view",
                                extra: {"announcement": ann});
                          },
                        );
                      },
                      itemCount: (state.announcements ?? []).length,
                      separatorBuilder: (context, index) {
                        return const Divider();
                      },
                    ),
            ),
          );
        },
      ),
    );
  }
}
