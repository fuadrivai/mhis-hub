import 'package:fl_mhis_hr/library/constant.dart';
import 'package:fl_mhis_hr/pages/payslip/bloc/payslip_bloc.dart';
import 'package:fl_mhis_hr/widget/themed_page.dart';
import 'package:fl_mhis_hr/widget/widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jiffy/jiffy.dart';
import 'package:url_launcher/url_launcher.dart';

class PaymentslipScreen extends StatefulWidget {
  const PaymentslipScreen({super.key});

  @override
  State<PaymentslipScreen> createState() => _PaymentslipScreenState();
}

class _PaymentslipScreenState extends State<PaymentslipScreen> {
  @override
  void initState() {
    super.initState();
    context.read<PayslipBloc>().add(const OnInit());
  }

  void _refresh() => context.read<PayslipBloc>().add(const OnInit());

  Future<void> _openLink(String? link) async {
    final uri = Uri.tryParse(link?.trim() ?? '');
    if (uri == null || !uri.hasScheme || !await launchUrl(uri)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to open payment slip link')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ThemedPage(
      title: 'Payment Slip',
      subtitle: 'View your payment slips',
      child: BlocBuilder<PayslipBloc, PayslipState>(
        builder: (context, state) {
          if (state.isLoading) return const LoadingWidget();
          final payslips = state.payslips ?? [];
          return RefreshIndicator(
            color: AppColors.danger,
            onRefresh: () async => _refresh(),
            child: state.isError || payslips.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    children: [
                      ThemedMessageCard(
                        message: state.isError
                            ? 'Unable to load payment slips'
                            : 'No payment slips found',
                        details: state.isError ? state.errorMessage : null,
                        onRetry: _refresh,
                      ),
                    ],
                  )
                : ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: payslips.length,
                    itemBuilder: (context, index) {
                      final payslip = payslips[index];
                      final rawPeriod = payslip.periode;
                      final period = rawPeriod == null
                          ? null
                          : DateTime.tryParse(rawPeriod);
                      final label = period == null
                          ? (rawPeriod == null || rawPeriod.isEmpty
                              ? '--'
                              : rawPeriod)
                          : Jiffy.parseFromDateTime(period)
                              .format(pattern: 'MMMM yyyy');
                      return TileWidget(
                        title: 'Periode : $label',
                        subtitle: 'Payment Slip',
                        onTap: () => _openLink(payslip.link),
                        accentColor: AppColors.danger,
                        icon: const FaIcon(FontAwesomeIcons.sackDollar,
                            color: AppColors.danger, size: 18),
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
