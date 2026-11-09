import 'package:fl_mhis_hr/library/constant.dart';
import 'package:fl_mhis_hr/pages/home/bloc/home_bloc.dart';
import 'package:fl_mhis_hr/widget/themed_page.dart';
import 'package:fl_mhis_hr/widget/widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class NewsletterScreen extends StatefulWidget {
  const NewsletterScreen({super.key});

  @override
  State<NewsletterScreen> createState() => _NewsletterScreenState();
}

class _NewsletterScreenState extends State<NewsletterScreen> {
  @override
  void initState() {
    super.initState();
    context.read<HomeBloc>().add(const OnGetNewsletter());
  }

  void _refreshNewsletter() =>
      context.read<HomeBloc>().add(const OnGetNewsletter());

  Future<void> _openNewsletterLink(String? link) async {
    final cleanLink = (link ?? '').trim();
    if (cleanLink.isEmpty) return;
    final uri = Uri.tryParse(cleanLink);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return ThemedPage(
      title: 'Newsletter',
      subtitle: 'Explore the latest newsletters',
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state.newsletterLoading) return const LoadingWidget();
          final newsletters = state.newsletters ?? [];
          return RefreshIndicator(
            color: AppColors.danger,
            onRefresh: () async => _refreshNewsletter(),
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 820),
                child: state.newsletterError || newsletters.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        children: [
                          ThemedMessageCard(
                            message: state.newsletterError
                                ? 'Unable to load newsletters'
                                : 'No newsletters found',
                            details: state.newsletterError
                                ? state.newsletterErrorMessage
                                : null,
                            onRetry: _refreshNewsletter,
                          ),
                        ],
                      )
                    : ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        itemCount: newsletters.length,
                        itemBuilder: (context, index) {
                          final newsletter = newsletters[index];
                          return TileWidget(
                            title: (newsletter.newsletter ?? '--').trim(),
                            subtitle: (newsletter.level ?? 'Level').trim(),
                            onTap: () => _openNewsletterLink(newsletter.link),
                            accentColor: AppColors.danger,
                            icon: const FaIcon(FontAwesomeIcons.newspaper,
                                color: AppColors.danger, size: 16),
                          );
                        },
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}
