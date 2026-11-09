import 'package:fl_mhis_hr/library/constant.dart';
import 'package:fl_mhis_hr/pages/home/bloc/home_bloc.dart';
import 'package:fl_mhis_hr/pages/home/repository/schedule_data_source.dart';
import 'package:fl_mhis_hr/widget/themed_page.dart';
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
  void dispose() {
    _calendarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ThemedPage(
      title: 'School Calendar',
      subtitle: 'View school events and schedules',
      onBack: () => Navigator.of(context).maybePop(),
      actions: [
        IconButton(
          onPressed: _reloadCalendar,
          icon: const Icon(Icons.refresh, color: Colors.white),
          tooltip: 'Refresh calendar',
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            if (state.calendarLoading) {
              return const LoadingWidget();
            }

            if (state.calendarError) {
              return ListView(
                children: [
                  ThemedMessageCard(
                    message: 'Unable to load calendar',
                    details: state.calendarErrorMessage,
                    buttonText: 'Try again',
                    onRetry: _reloadCalendar,
                  ),
                ],
              );
            }

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 24),
              child: Container(
                height: 744,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: AppColors.danger.withValues(alpha: 0.1)),
                ),
                child: SfCalendar(
                  controller: _calendarController,
                  view: CalendarView.month,
                  initialDisplayDate: DateTime.now(),
                  timeZone: 'SE Asia Standard Time',
                  headerHeight: 50,
                  headerDateFormat: 'MMMM y',
                  showDatePickerButton: true,
                  showNavigationArrow: true,
                  todayHighlightColor: AppColors.danger,
                  selectionDecoration: BoxDecoration(
                    border: Border.all(color: AppColors.danger, width: 2),
                    borderRadius: BorderRadius.circular(6),
                  ),
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
