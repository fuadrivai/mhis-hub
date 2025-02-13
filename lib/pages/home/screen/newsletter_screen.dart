import 'package:fl_mhis_hr/library/constant.dart';
import 'package:fl_mhis_hr/models/model.dart';
import 'package:fl_mhis_hr/pages/home/bloc/home_bloc.dart';
import 'package:fl_mhis_hr/widget/widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class NewsletterScreen extends StatefulWidget {
  const NewsletterScreen({super.key});

  @override
  State<NewsletterScreen> createState() => _NewsletterScreenState();
}

class _NewsletterScreenState extends State<NewsletterScreen> {
  @override
  void initState() {
    context.read<HomeBloc>().add(const OnGetNewsletter());
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
        title: "Newsletter",
      ),
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state.newsletterLoading) {
            return const LoadingWidget();
          }
          return RefreshIndicator(
            onRefresh: () async {
              context.read<HomeBloc>().add(const OnGetNewsletter());
            },
            child: Container(
              decoration: const BoxDecoration(color: AppColors.white),
              child: (state.newsletters ?? []).isEmpty
                  ? EmptyWidget(
                      onTap: () {
                        context.read<HomeBloc>().add(const OnGetNewsletter());
                      },
                    )
                  : ListView.separated(
                      itemCount: (state.newsletters ?? []).length,
                      itemBuilder: (ctx, i) {
                        Newsletter e = state.newsletters![i];
                        return ListTile(
                          dense: false,
                          visualDensity: const VisualDensity(vertical: -1),
                          title: Text(
                            e.newsletter ?? "--",
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(e.level ?? "Level"),
                          leading: const FaIcon(
                            FontAwesomeIcons.newspaper,
                            color: AppColors.secondary,
                          ),
                          onTap: () {
                            if (e.link != null || e.link != "") {
                              launchUrl(Uri.parse(e.link!));
                            }
                          },
                        );
                      },
                      separatorBuilder: (ctx, i) {
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
