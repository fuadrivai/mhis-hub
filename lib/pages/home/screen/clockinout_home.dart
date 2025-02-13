import 'package:fl_mhis_hr/pages/home/bloc/home_bloc.dart';
import 'package:fl_mhis_hr/widget/widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ClockInOutHome extends StatefulWidget {
  const ClockInOutHome({super.key});

  @override
  State<ClockInOutHome> createState() => _ClockInOutHomeState();
}

class _ClockInOutHomeState extends State<ClockInOutHome> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state.attendanceLoading) {
          return const LoadingShimmer(height: 150);
        }
        if (state.attendanceError) {
          return Center(child: Text(state.attendanceErrorMessage ?? "Error"));
        }
        return CardClockInOut(schedule: state.attendaceSchedule);
      },
    );
  }
}
