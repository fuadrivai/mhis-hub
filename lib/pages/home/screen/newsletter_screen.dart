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

  Future<void> _refreshNewsletter() async {
    context.read<HomeBloc>().add(const OnGetNewsletter());
  }

  Future<void> _openNewsletterLink(String? link) async {
    final String cleanLink = (link ?? '').trim();
    if (cleanLink.isEmpty) return;

    final Uri? uri = Uri.tryParse(cleanLink);
    if (uri == null) return;

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final bool isWide = size.width >= 700;
    final double horizontalPadding = isWide ? 24 : 12;
    final double contentMaxWidth = isWide ? 820 : double.infinity;

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

          final List<Newsletter> newsletters = state.newsletters ?? [];

          return RefreshIndicator(
            onRefresh: _refreshNewsletter,
            child: Container(
              color: AppColors.white,
              child: newsletters.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                        vertical: 24,
                      ),
                      children: [
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: contentMaxWidth,
                          ),
                          child: EmptyWidget(
                            onTap: () {
                              context.read<HomeBloc>().add(
                                    const OnGetNewsletter(),
                                  );
                            },
                          ),
                        ),
                      ],
                    )
                  : Align(
                      alignment: Alignment.topCenter,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: contentMaxWidth),
                        child: ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.fromLTRB(
                            horizontalPadding,
                            16,
                            horizontalPadding,
                            20,
                          ),
                          itemCount: newsletters.length,
                          itemBuilder: (ctx, i) {
                            final Newsletter newsletter = newsletters[i];

                            return TileWidget(
                              title: (newsletter.newsletter ?? '--').trim(),
                              subtitle: (newsletter.level ?? 'Level').trim(),
                              onTap: () => _openNewsletterLink(newsletter.link),
                              icon: const FaIcon(
                                FontAwesomeIcons.newspaper,
                                color: AppColors.secondary,
                                size: 16,
                              ),
                            );
                          },
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                        ),
                      ),
                    ),
            ),
          );
        },
      ),
    );
  }
}
