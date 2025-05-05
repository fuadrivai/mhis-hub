import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fl_mhis_hr/library/constant.dart';
import 'package:fl_mhis_hr/pages/home/bloc/home_bloc.dart';
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
  @override
  void initState() {
    DateTime now = DateTime.now();
    _calendarController.selectedDate = DateTime(now.year, now.month, now.day);
    context.read<HomeBloc>().add(const OnInitAttendance());
    context.read<HomeBloc>().add(const OnInitCalendar());

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      if (!mounted) return;
      Common.flushBar(
        context,
        title: message.notification?.title ?? "",
        message: message.notification?.body ?? "",
      );
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
        context.read<HomeBloc>().add(const OnInitCalendar());
      },
      child: Scaffold(
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
          title: "Home",
        ),
        body: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              const ClockInOutHome(),
              const CalendarCard(),
              const SizedBox(height: 10),
              const InformationHomeWidget()
            ],
          ),
        ),
      ),
    );
  }
}
