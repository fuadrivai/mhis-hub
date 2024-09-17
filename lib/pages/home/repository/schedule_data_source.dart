import 'package:color_parser/color_parser.dart';
import 'package:fl_mhis_hr/models/model.dart';
import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class ScheduleDataSource extends CalendarDataSource {
  ScheduleDataSource(List<SchoolCalendar> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return Jiffy.parse(appointments![index].starttime).dateTime;
  }

  @override
  DateTime getEndTime(int index) {
    return Jiffy.parse(appointments![index].endtime).dateTime;
  }

  @override
  String getSubject(int index) {
    return appointments![index].subject;
  }

  @override
  Color getColor(int index) {
    return ColorParser.hex(appointments![index].color).getColor()!;
  }
}
