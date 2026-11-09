import 'package:fl_mhis_hr/library/constant.dart';
import 'package:fl_mhis_hr/pages/home/bloc/home_bloc.dart';
import 'package:fl_mhis_hr/widget/themed_page.dart';
import 'package:fl_mhis_hr/widget/widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SopScreen extends StatefulWidget {
  const SopScreen({super.key});

  @override
  State<SopScreen> createState() => _SopScreenState();
}

class _SopScreenState extends State<SopScreen> {
  @override
  void initState() {
    super.initState();
    context.read<HomeBloc>().add(const OnGetSop());
  }

  void _refreshSops() => context.read<HomeBloc>().add(const OnGetSop());

  @override
  Widget build(BuildContext context) {
    return ThemedPage(
      title: 'SOP',
      subtitle: 'Standard operating procedures',
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state.sopLoading) return const LoadingWidget();
          final sops = state.sops ?? [];
          return RefreshIndicator(
            color: AppColors.danger,
            onRefresh: () async => _refreshSops(),
            child: state.sopError || sops.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    children: [
                      ThemedMessageCard(
                        message: state.sopError
                            ? 'SOP gagal dimuat.'
                            : 'No SOP found',
                        details: state.sopError ? state.sopErrorMessage : null,
                        buttonText: state.sopError ? 'Coba lagi' : 'Refresh',
                        onRetry: _refreshSops,
                      ),
                    ],
                  )
                : ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: sops.length,
                    itemBuilder: (context, index) {
                      final sop = sops[index];
                      return TileWidget(
                        title: (sop.title ?? '--').trim(),
                        subtitle: 'Standard Operating Procedure',
                        onTap: () {
                          final link = (sop.link ?? '').trim();
                          if (link.isNotEmpty) Common.launchExternalUrl(link);
                        },
                        accentColor: AppColors.danger,
                        icon: const FaIcon(FontAwesomeIcons.fileLines,
                            color: AppColors.danger, size: 16),
                      );
                    },
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                  ),
          );
        },
      ),
    );
  }
}
