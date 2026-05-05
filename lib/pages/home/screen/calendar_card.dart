import 'package:fl_mhis_hr/pages/home/bloc/home_bloc.dart';
import 'package:fl_mhis_hr/pages/home/repository/schedule_data_source.dart';
import 'package:fl_mhis_hr/widget/widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class CalendarCard extends StatefulWidget {
  const CalendarCard({super.key});

  @override
  State<CalendarCard> createState() => _CalendarCardState();
}

class _CalendarCardState extends State<CalendarCard> {
  final CalendarController _calendarController = CalendarController();
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state.calendarLoading) {
          return const LoadingShimmer(height: 380);
        }
        if (state.calendarError) {
          return Center(
            child: Text(state.calendarErrorMessage ?? "Error"),
          );
        }
        return Container(
          padding: const EdgeInsets.all(8),
          color: Colors.white,
          height: 380,
          child: Column(
            children: [
              const TextTitle(title: "School Calendar"),
              SfCalendar(
                headerHeight: 25,
                headerDateFormat: "MMMM y",
                timeZone: 'SE Asia Standard Time',
                view: CalendarView.month,
                controller: _calendarController,
                initialDisplayDate: DateTime.now(),
                monthViewSettings: const MonthViewSettings(
                  showAgenda: true,
                  agendaItemHeight: 28,
                  agendaViewHeight: 60,
                ),
                dataSource: ScheduleDataSource(state.calendarSchool ?? []),
              ),
            ],
          ),
        );
      },
    );
  }
}
