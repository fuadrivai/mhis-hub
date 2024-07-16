import 'package:fl_mhis_hr/library/constant.dart';
import 'package:fl_mhis_hr/pages/home/bloc/home_bloc.dart';
import 'package:fl_mhis_hr/widget/widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

class PaymentslipScreen extends StatefulWidget {
  const PaymentslipScreen({super.key});

  @override
  State<PaymentslipScreen> createState() => _PaymentslipScreenState();
}

class _PaymentslipScreenState extends State<PaymentslipScreen> {
  @override
  void initState() {
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
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state.newsletterLoading) {
            return const LoadingWidget();
          }
          return ListView.separated(
            itemCount: (state.newsletters ?? []).length,
            itemBuilder: (ctx, i) {
              return ListTile(
                title: const Text("Payment Slip"),
                subtitle: const Text("Subtitle"),
                leading: const FaIcon(
                  FontAwesomeIcons.sackDollar,
                  color: AppColors.secondary,
                ),
                onTap: () {},
              );
            },
            separatorBuilder: (ctx, i) {
              return const Divider();
            },
          );
        },
      ),
    );
  }
}
