import 'package:fl_mhis_hr/models/v2/models.dart';

class Attendance {
  int? id;
  int? employeeId;
  int? userId;
  String? date;
  String? status;
  String? fullname;
  String? shiftName;
  int? holiday;
  String? scheduleIn;
  String? scheduleOut;
  String? checkIn;
  String? checkInPhoto;
  double? checkInLatitude;
  double? checkInLongitude;
  double? checkInRadius;
  String? checkOut;
  String? checkOutPhoto;
  double? checkOutLatitude;
  double? checkOutLongitude;
  double? checkOutRadius;
  Employee? employee;
  List<AttendanceLog>? logs;

  Attendance({
    this.id,
    this.employeeId,
    this.userId,
    this.date,
    this.status,
    this.fullname,
    this.shiftName,
    this.holiday,
    this.scheduleIn,
    this.scheduleOut,
    this.checkIn,
    this.checkInPhoto,
    this.checkInLatitude,
    this.checkInLongitude,
    this.checkInRadius,
    this.checkOut,
    this.checkOutPhoto,
    this.checkOutLatitude,
    this.checkOutLongitude,
    this.checkOutRadius,
    this.employee,
    this.logs,
  });

  Attendance.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    employeeId = json['employee_id'];
    userId = json['user_id'];
    date = json['date'];
    status = json['status'];
    fullname = json['fullname'];
    shiftName = json['shift_name'];
    holiday = json['holiday'];
    scheduleIn = json['schedule_in'];
    scheduleOut = json['schedule_out'];
    checkIn = json['check_in'];
    checkInPhoto = json['check_in_photo'];
    checkInLatitude = json['check_in_latitude'];
    checkInLongitude = json['check_in_longitude'];
    checkInRadius = json['check_in_radius'];
    checkOut = json['check_out'];
    checkOutPhoto = json['check_out_photo'];
    checkOutLatitude = json['check_out_latitude'];
    checkOutLongitude = json['check_out_longitude'];
    checkOutRadius = json['check_out_radius'];
    employee =
        json['employee'] != null ? Employee.fromJson(json['employee']) : null;
    logs = json['logs'] != null
        ? (json['logs'] as List).map((e) => AttendanceLog.fromJson(e)).toList()
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['employee_id'] = employeeId;
    data['user_id'] = userId;
    data['date'] = date;
    data['status'] = status;
    data['fullname'] = fullname;
    data['shift_name'] = shiftName;
    data['holiday'] = holiday;
    data['schedule_in'] = scheduleIn;
    data['schedule_out'] = scheduleOut;
    data['check_in'] = checkIn;
    data['check_in_photo'] = checkInPhoto;
    data['check_in_latitude'] = checkInLatitude;
    data['check_in_longitude'] = checkInLongitude;
    data['check_in_radius'] = checkInRadius;
    data['check_out'] = checkOut;
    data['check_out_photo'] = checkOutPhoto;
    data['check_out_latitude'] = checkOutLatitude;
    data['check_out_longitude'] = checkOutLongitude;
    data['check_out_radius'] = checkOutRadius;
    if (employee != null) {
      data['employee'] = employee!.toJson();
    }
    if (logs != null) {
      data['logs'] = logs!.map((e) => e.toJson()).toList();
    }
    return data;
  }
}
