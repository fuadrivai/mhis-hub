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
    double topBarOpacity = 0.0;
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
                    headerHeight: 30,
                    cellEndPadding: -1,
                    headerDateFormat: "MMMM y",
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
                const SizedBox(height: 10),
                Container(
                  color: AppColors.white,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 5,
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Widget",
                            style: TextStyle(
                              color: AppColors.dismissibleBackground,
                              fontWeight: FontWeight.w600,
                              fontSize: 15 + 6 - 6 * topBarOpacity,
                            ),
                          ),
                        ),
                      ),
                      const Divider(),
                      listTile(
                        title: "Payment Slip",
                        iconData: FontAwesomeIcons.dollarSign,
                      ),
                      listTile(
                        title: "Attendance",
                        iconData: FontAwesomeIcons.rightToBracket,
                      ),
                      listTile(
                        title: "Newsletter",
                        iconData: FontAwesomeIcons.newspaper,
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget listTile({
    required String title,
    required IconData iconData,
    GestureTapCallback? onTap,
  }) {
    return ListTile(
      dense: true,
      title: Text(title),
      leading: FaIcon(
        iconData,
        size: 35,
        color: AppColors.primary2,
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios_rounded,
        color: Color.fromARGB(255, 101, 101, 101),
        size: 15,
      ),
      onTap: onTap,
    );
  }
}
