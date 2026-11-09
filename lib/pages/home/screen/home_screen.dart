import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fl_mhis_hr/library/constant.dart';
import 'package:fl_mhis_hr/pages/home/bloc/home_bloc.dart';
import 'package:fl_mhis_hr/pages/home/screen/announcement_card.dart';
import 'package:fl_mhis_hr/pages/home/screen/home_header.dart';
import 'package:fl_mhis_hr/pages/employee/repository/employee_api.dart';
import 'package:fl_mhis_hr/models/v2/employee.dart';
import 'package:fl_mhis_hr/pages/pages.dart';
import 'package:fl_mhis_hr/widget/widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class HomeScreen extends StatefulWidget {
  final AnimationController? animationController;
  const HomeScreen({super.key, this.animationController});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CalendarController _calendarController = CalendarController();
  late Future<Employee> _profile;
  @override
  void initState() {
    DateTime now = DateTime.now();
    _calendarController.selectedDate = DateTime(now.year, now.month, now.day);
    context.read<HomeBloc>().add(const OnInitAttendance());
    // context.read<HomeBloc>().add(const OnInitCalendar());
    context.read<HomeBloc>().add(const OnInitAnnouncement());
    _profile = EmployeeApi.getEmployeeProfile();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (!mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Common.flushBar(
          context,
          title: message.notification?.title ?? "",
          message: message.notification?.body ?? "",
        );
      });
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      // ignore: avoid_print
      print('App opened by notification: ${message.notification?.title}');
    });

    handleTerminatedState();
    super.initState();
  }

  Future<void> handleTerminatedState() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    RemoteMessage? initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) {
      if (!mounted) return;
      Common.flushBar(
        context,
        title: initialMessage.notification?.title ?? "",
        message: initialMessage.notification?.body ?? "",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<HomeBloc>().add(const OnInitAttendance());
        // context.read<HomeBloc>().add(const OnInitCalendar());
        context.read<HomeBloc>().add(const OnInitAnnouncement());
        setState(() {
          _profile = EmployeeApi.getEmployeeProfile();
        });
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F8FA),
        body: Stack(
          children: [
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              height: MediaQuery.paddingOf(context).top + 220,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: Common.homeHeaderGradient,
                ),
              ),
            ),
            SafeArea(
              bottom: false,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(top: 20, bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: FutureBuilder<Employee>(
                        future: _profile,
                        builder: (context, profile) =>
                            BlocBuilder<HomeBloc, HomeState>(
                          builder: (context, state) => HomeHeader(
                            name: state.shift?.fullname ??
                                profile.data?.personal?.fullname,
                            avatar: profile.data?.personal?.avatar,
                            hour: DateTime.now().hour,
                            profileError: profile.hasError,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: ClockInOutHome(),
                    ),
                    const SizedBox(height: 18),
                    const InformationHomeWidget(),
                    const SizedBox(height: 8),
                    const AnnouncementCard(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
