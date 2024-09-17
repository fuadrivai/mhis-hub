import 'package:fl_mhis_hr/models/model.dart';

class AttendanceResponse {
  String? message;
  DataAttendance? data;

  AttendanceResponse({this.message, this.data});

  AttendanceResponse.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    data = json['data'] != null ? DataAttendance.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}
