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
          return RefreshIndicator(
            onRefresh: () async {
              context.read<PayslipBloc>().add(const OnInit());
            },
            child: Container(
              decoration: const BoxDecoration(color: AppColors.white),
              child: (state.payslips ?? []).isEmpty
                  ? EmptyWidget(
                      onTap: () {
                        context.read<PayslipBloc>().add(const OnInit());
                      },
                    )
                  : ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: (state.payslips ?? []).length,
                      itemBuilder: (ctx, i) {
                        Payslip payslip = (state.payslips ?? [])[i];
                        return ListTile(
                          title: Text(
                              "Periode : ${Jiffy.parse(payslip.periode!).format(pattern: "MMMM yyyy")}"),
                          subtitle: const Text("Payment Slip"),
                          leading: const FaIcon(
                            FontAwesomeIcons.sackDollar,
                            color: AppColors.secondary,
                          ),
                          onTap: () {
                            if (payslip.link != null || payslip.link != "") {
                              launchUrl(Uri.parse(payslip.link!));
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
