import 'package:fl_mhis_hr/library/constant.dart';
import 'package:fl_mhis_hr/pages/timeoff/bloc/timeoff_bloc.dart';
import 'package:fl_mhis_hr/widget/widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TimeoffScreen2 extends StatefulWidget {
  const TimeoffScreen2({super.key});

  @override
  State<TimeoffScreen2> createState() => _TimeoffScreen2State();
}

class _TimeoffScreen2State extends State<TimeoffScreen2> {
  @override
  void initState() {
    super.initState();
    context.read<TimeoffBloc>().add(const OnInit());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: CustomAppbar(
        backgroundColor: AppColors.whiteshade,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
        title: "Request Timeoff",
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.whiteshade,
              Color(0xFFEAF0FF),
              AppColors.white,
            ],
          ),
        ),
        child: BlocBuilder<TimeoffBloc, TimeoffState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const LoadingWidget();
            }
            return RefreshIndicator(
              onRefresh: () async {
                context.read<TimeoffBloc>().add(const OnInit());
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  TimeoffListWidget(timeoffs: state.timeoffs ?? []),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
