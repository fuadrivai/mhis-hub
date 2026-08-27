import 'package:fl_mhis_hr/models/v2/models.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Menu {
  Menu._();

  static const List<GridMenuItem> front = [
    GridMenuItem(
      title: 'Timeoff',
      icon: FontAwesomeIcons.suitcase,
      routeCandidates: ['timeoff-approval', 'leave'],
      seed: 101,
    ),
    GridMenuItem(
      title: 'Live Attendance',
      icon: FontAwesomeIcons.userCheck,
      routeCandidates: ['attendance-screen'],
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
      routeCandidates: ['employee-contact'],
      seed: 707,
    ),
    GridMenuItem(
      title: 'Newsletter',
      icon: FontAwesomeIcons.newspaper,
      routeCandidates: ['announcement'],
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
      title: 'Timeoff',
      icon: FontAwesomeIcons.suitcase,
      routeCandidates: ['timeoff-approval'],
      seed: 101,
    ),
    GridMenuItem(
      title: 'Live Attendance',
      icon: FontAwesomeIcons.userCheck,
      routeCandidates: ['attendance-screen'],
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
      routeCandidates: ['employee-contact'],
      seed: 707,
    ),
    GridMenuItem(
      title: 'Newsletter',
      icon: FontAwesomeIcons.newspaper,
      routeCandidates: ['announcement'],
      seed: 808,
    ),
    GridMenuItem(
      title: 'General Newsletter',
      icon: FontAwesomeIcons.newspaper,
      routeCandidates: ['general-announcement'],
      seed: 150,
    ),
    GridMenuItem(
      title: 'Calendar',
      icon: FontAwesomeIcons.calendarDays,
      routeCandidates: ["school-calendar"],
      seed: 909,
    ),
    GridMenuItem(
      title: 'All Attendance',
      icon: FontAwesomeIcons.clipboardList,
      routeCandidates: ["attendance-all"],
      seed: 202,
    ),
    GridMenuItem(
      title: 'Time Off Requests',
      icon: FontAwesomeIcons.suitcase,
      routeCandidates: ["timeoff-requests"],
      seed: 303,
    ),
  ];
}
