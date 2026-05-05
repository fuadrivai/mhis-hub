import 'package:fl_mhis_hr/library/constant.dart';
import 'package:fl_mhis_hr/models/model.dart';
import 'package:fl_mhis_hr/pages/payslip/bloc/payslip_bloc.dart';
import 'package:fl_mhis_hr/widget/widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
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
    context.read<PayslipBloc>().add(const OnInit());
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
        title: "Payment Slip",
      ),
      body: BlocBuilder<PayslipBloc, PayslipState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const LoadingWidget();
          }

          if ((state.payslips?.isEmpty ?? true)) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "There are currently no payslips available. Please check back later.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<PayslipBloc>().add(const OnInit());
            },
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: state.payslips?.length ?? 0,
              itemBuilder: (ctx, i) {
                Payslip payslip = state.payslips![i];
                return ListTile(
                  title: Text(
                      "Periode : ${Jiffy.parse(payslip.periode!).format(pattern: "MMMM yyyy")}"),
                  subtitle: const Text("Payment Slip"),
                  leading: const FaIcon(
                    FontAwesomeIcons.sackDollar,
                    color: AppColors.secondary,
                  ),
                  onTap: () {
                    if (payslip.link != null && payslip.link!.isNotEmpty) {
                      launchUrl(Uri.parse(payslip.link!));
                    }
                  },
                );
              },
              separatorBuilder: (ctx, i) {
                return const Divider();
              },
            ),
          );
        },
      ),
    );
  }
}
