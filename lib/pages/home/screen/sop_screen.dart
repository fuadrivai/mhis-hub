import 'package:fl_mhis_hr/library/constant.dart';
import 'package:fl_mhis_hr/models/v2/models.dart';
import 'package:fl_mhis_hr/pages/home/bloc/home_bloc.dart';
import 'package:fl_mhis_hr/widget/widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

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

  Future<void> _refreshSops() async {
    context.read<HomeBloc>().add(const OnGetSop());
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
        title: 'SOP',
      ),
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state.sopLoading) return const LoadingWidget();

          final List<Sop> sops = state.sops ?? [];
          return RefreshIndicator(
            onRefresh: _refreshSops,
            child: Container(
              color: AppColors.white,
              child: state.sopError
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        const SizedBox(height: 100),
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              children: [
                                const Text('SOP gagal dimuat.'),
                                if (state.sopErrorMessage != null) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    state.sopErrorMessage!,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ],
                                const SizedBox(height: 12),
                                TextButton(
                                  onPressed: _refreshSops,
                                  child: const Text('Coba lagi'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  : sops.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            const SizedBox(height: 80),
                            EmptyWidget(onTap: _refreshSops),
                          ],
                        )
                      : ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 16,
                          ),
                          itemCount: sops.length,
                          itemBuilder: (context, index) {
                            final sop = sops[index];
                            return TileWidget(
                              title: (sop.title ?? '--').trim(),
                              subtitle: 'Standard Operating Procedure',
                              onTap: () {
                                final link = (sop.link ?? '').trim();
                                if (link.isNotEmpty) {
                                  Common.launchExternalUrl(link);
                                }
                              },
                              icon: const FaIcon(
                                FontAwesomeIcons.fileLines,
                                color: AppColors.secondary,
                                size: 16,
                              ),
                            );
                          },
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                        ),
            ),
          );
        },
      ),
    );
  }
}
