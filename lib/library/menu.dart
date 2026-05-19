import 'package:fl_mhis_hr/models/v2/models.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Menu {
  Menu._();

  static const List<GridMenuItem> front = [
    GridMenuItem(
      title: 'Timeoff',
      icon: FontAwesomeIcons.suitcase,
      routeCandidates: ['timeoff', 'leave'],
      seed: 101,
    ),
    GridMenuItem(
      title: 'Live Attendance',
      icon: FontAwesomeIcons.userCheck,
      routeCandidates: ['live-attendance', 'live-ashar'],
      seed: 202,
    ),
    GridMenuItem(
      title: 'Attendance Log',
      icon: FontAwesomeIcons.clipboardList,
      routeCandidates: ['attendance-history'],
      seed: 303,
    ),
    GridMenuItem(
      title: 'Payslip',
      icon: FontAwesomeIcons.fileInvoiceDollar,
      routeCandidates: ['paymentsllip'],
      seed: 404,
    ),
    GridMenuItem(
      title: 'KPI Score',
      icon: FontAwesomeIcons.chartLine,
      routeCandidates: ['kpi'],
      seed: 606,
    ),
    GridMenuItem(
      title: 'Contact',
      icon: FontAwesomeIcons.addressBook,
      routeCandidates: ['contact'],
      seed: 707,
    ),
    GridMenuItem(
      title: 'Newsletter',
      icon: FontAwesomeIcons.newspaper,
      routeCandidates: ['announcement', 'general-announcement'],
      seed: 808,
    ),
    GridMenuItem(
      title: 'All Apps',
      icon: FontAwesomeIcons.list,
      routeCandidates: [],
      seed: 505,
    ),
  ];

  static const List<GridMenuItem> dialog = [
    GridMenuItem(
      title: 'Calendar',
      icon: FontAwesomeIcons.calendarDays,
      routeCandidates: [],
      seed: 909,
    ),
    GridMenuItem(
      title: 'Timeoff',
      icon: FontAwesomeIcons.suitcase,
      routeCandidates: ['timeoff'],
      seed: 101,
    ),
    GridMenuItem(
      title: 'Live Attendance',
      icon: FontAwesomeIcons.userCheck,
      routeCandidates: ['live-attendance', 'live-ashar'],
      seed: 202,
    ),
    GridMenuItem(
      title: 'Attendance Log',
      icon: FontAwesomeIcons.clipboardList,
      routeCandidates: ['attendance-history'],
      seed: 303,
    ),
    GridMenuItem(
      title: 'Payslip',
      icon: FontAwesomeIcons.fileInvoiceDollar,
      routeCandidates: ['paymentsllip', 'payslip'],
      seed: 404,
    ),
    GridMenuItem(
      title: 'KPI Score',
      icon: FontAwesomeIcons.chartLine,
      routeCandidates: ['kpi'],
      seed: 606,
    ),
    GridMenuItem(
      title: 'Contact',
      icon: FontAwesomeIcons.addressBook,
      routeCandidates: ['contact'],
      seed: 707,
    ),
    GridMenuItem(
      title: 'Newsletter',
      icon: FontAwesomeIcons.newspaper,
      routeCandidates: ['announcement', 'general-announcement'],
      seed: 808,
    ),
  ];
}
