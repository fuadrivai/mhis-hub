import 'package:fl_mhis_hr/models/v2/models.dart';

class AttendanceLog {
  String? type;
  String? fullname;
  String? shiftName;
  String? photo;
  double? latitude;
  double? longitude;
  double? radius;
  String? clockDatetime;
  String? clockDate;
  String? time;
  int? id;
  Attendance? attendance;
  Employee? employee;

  AttendanceLog({
    this.type,
    this.fullname,
    this.shiftName,
    this.photo,
    this.latitude,
    this.longitude,
    this.radius,
    this.clockDatetime,
    this.clockDate,
    this.time,
    this.id,
    this.attendance,
    this.employee,
  });

  AttendanceLog.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    fullname = json['fullname'];
    shiftName = json['shift_name'];
    photo = json['photo'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    radius = json['radius'];
    clockDatetime = json['clock_datetime'];
    clockDate = json['clock_date'];
    time = json['time'];
    id = json['id'];
    attendance = json['attendance'] != null
        ? Attendance.fromJson(json['attendance'])
        : null;
    employee =
        json['employee'] != null ? Employee.fromJson(json['employee']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['type'] = type;
    data['fullname'] = fullname;
    data['shift_name'] = shiftName;
    data['photo'] = photo;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['radius'] = radius;
    data['clock_datetime'] = clockDatetime;
    data['clock_date'] = clockDate;
    data['time'] = time;
    data['id'] = id;
    if (attendance != null) {
      data['attendance'] = attendance!.toJson();
    }
    if (employee != null) {
      data['employee'] = employee!.toJson();
    }
    return data;
  }
}
