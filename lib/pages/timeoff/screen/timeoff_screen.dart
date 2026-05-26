// ignore_for_file: deprecated_member_use

import 'package:fl_mhis_hr/library/constant.dart';
import 'package:fl_mhis_hr/pages/timeoff/bloc/timeoff_bloc.dart';
import 'package:fl_mhis_hr/widget/widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TimeoffScreen extends StatefulWidget {
  const TimeoffScreen({super.key});

  @override
  State<TimeoffScreen> createState() => _TimeoffScreenState();
}

class _TimeoffScreenState extends State<TimeoffScreen> {
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
        leading: Container(
          padding: const EdgeInsets.only(left: 10),
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Image.asset(Common.imageLogo),
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
          child:
              BlocBuilder<TimeoffBloc, TimeoffState>(builder: (context, state) {
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
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                      child: _buildHeroCard(),
                    ),
                  ),
                  TimeoffListWidget(timeoffs: state.timeoffs ?? []),
                ],
              ),
            );
          })),
    );
  }

  Widget _buildHeroCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: Common.redGradient,
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withOpacity(0.18),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Available Timeoff',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Choose a timeoff type to complete your request',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.white.withOpacity(0.85),
                ),
          ),
        ],
      ),
    );
  }
}
