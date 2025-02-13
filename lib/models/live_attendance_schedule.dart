import 'package:jiffy/jiffy.dart';

class LiveAttendanceSchedule {
  String? currentShiftDate;
  int? currentShiftId;
  String? currentShiftName;
  String? currentShiftScIn;
  String? currentShiftScOut;
  String? fullDateTime;

  LiveAttendanceSchedule({
    this.currentShiftDate,
    this.currentShiftId,
    this.currentShiftName,
    this.currentShiftScIn,
    this.currentShiftScOut,
    this.fullDateTime,
  });

  LiveAttendanceSchedule.fromJson(Map<String, dynamic> json) {
    currentShiftDate = json['current_shift_date'];
    currentShiftId = json['current_shift_id'];
    currentShiftName = json['current_shift_name'];
    currentShiftScIn = json['current_shift_sc_in'];
    currentShiftScOut = json['current_shift_sc_out'];
    String fullDate = "--";
    if (currentShiftDate != null) {
      String date =
          Jiffy.parse(currentShiftDate!).format(pattern: "dd MMMM yyyy");
      String start = Jiffy.parse(currentShiftScIn!, pattern: "HH:mm:ss")
          .format(pattern: "HH:mm");
      String end = Jiffy.parse(currentShiftScOut!, pattern: "HH:mm:ss")
          .format(pattern: "HH:mm");
      fullDate = "$date ($start - $end)";
    }
    fullDateTime = fullDate;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['current_shift_date'] = currentShiftDate;
    data['current_shift_id'] = currentShiftId;
    data['current_shift_name'] = currentShiftName;
    data['current_shift_sc_in'] = currentShiftScIn;
    data['current_shift_sc_out'] = currentShiftScOut;
    return data;
  }
}
