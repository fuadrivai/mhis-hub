import 'package:fl_mhis_hr/library/constant.dart';
import 'package:fl_mhis_hr/pages/home/bloc/home_bloc.dart';
import 'package:fl_mhis_hr/pages/home/repository/schedule_data_source.dart';
import 'package:fl_mhis_hr/widget/widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class HomeScreen extends StatefulWidget {
  final AnimationController? animationController;
  const HomeScreen({super.key, this.animationController});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CalendarController _calendarController = CalendarController();
  @override
  void initState() {
    DateTime now = DateTime.now();
    _calendarController.selectedDate = DateTime(now.year, now.month, now.day);
    context.read<HomeBloc>().add(const OnGetSchoolCalendar());
    super.initState();
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
        title: "Dashboard",
      ),
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          return SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  color: Colors.white,
                  height: 370,
                  child: SfCalendar(
                    timeZone: 'SE Asia Standard Time',
                    view: CalendarView.month,
                    controller: _calendarController,
                    initialDisplayDate: DateTime.now(),
                    monthViewSettings: const MonthViewSettings(
                      showAgenda: true,
                      agendaItemHeight: 60,
                    ),
                    dataSource: ScheduleDataSource(state.schedules ?? []),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10.0, vertical: 10),
                  child: GridView(
                    shrinkWrap: true,
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 100,
                      childAspectRatio: 1,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    children: const [
                      WidgetBox(
                        label: "Payment Slip",
                        icon: Icon(
                          FontAwesomeIcons.dollarSign,
                          size: 35,
                          color: AppColors.primary2,
                        ),
                      ),
                      WidgetBox(
                        label: "Attendande",
                        icon: Icon(
                          FontAwesomeIcons.signHanging,
                          size: 35,
                          color: AppColors.primary2,
                        ),
                      ),
                      WidgetBox(
                        label: "Payment Slip",
                        icon: Icon(
                          FontAwesomeIcons.dollarSign,
                          size: 35,
                          color: AppColors.primary2,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
