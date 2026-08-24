import 'package:fl_mhis_hr/library/constant.dart';
import 'package:fl_mhis_hr/pages/home/bloc/home_bloc.dart';
import 'package:fl_mhis_hr/pages/home/repository/schedule_data_source.dart';
import 'package:fl_mhis_hr/widget/widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final CalendarController _calendarController = CalendarController();

  @override
  void initState() {
    super.initState();
    context.read<HomeBloc>().add(const OnInitCalendar());
  }

  void _reloadCalendar() {
    context.read<HomeBloc>().add(const OnInitCalendar());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        backgroundColor: AppColors.whiteshade,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back',
        ),
        title: 'School Calendar',
        actions: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: _reloadCalendar,
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh calendar',
            ),
          ],
        ),
      ),
      body: Container(
        color: AppColors.white,
        padding: const EdgeInsets.all(12),
        child: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            if (state.calendarLoading) {
              return const LoadingWidget();
            }

            if (state.calendarError) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(state.calendarErrorMessage ??
                        'Unable to load calendar'),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: _reloadCalendar,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Try again'),
                    ),
                  ],
                ),
              );
            }

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 24),
              child: SizedBox(
                height: 720,
                child: SfCalendar(
                  controller: _calendarController,
                  view: CalendarView.month,
                  initialDisplayDate: DateTime.now(),
                  timeZone: 'SE Asia Standard Time',
                  headerHeight: 50,
                  headerDateFormat: 'MMMM y',
                  showDatePickerButton: true,
                  showNavigationArrow: true,
                  monthViewSettings: const MonthViewSettings(
                    showAgenda: true,
                    agendaItemHeight: 36,
                    agendaViewHeight: 180,
                  ),
                  dataSource: ScheduleDataSource(state.calendarSchool ?? []),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
