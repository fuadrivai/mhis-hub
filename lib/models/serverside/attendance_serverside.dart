import 'package:fl_mhis_hr/models/model.dart';
import 'package:fl_mhis_hr/models/v2/models.dart';

class ServerSideAttendance {
  List<Attendance>? atendances;
  Pagination? pagination;

  ServerSideAttendance({this.atendances, this.pagination});

  ServerSideAttendance.fromJson(Map<String, dynamic> json) {
    if (json['atendances'] != null) {
      atendances = <Attendance>[];
      json['atendances'].forEach((v) {
        atendances!.add(Attendance.fromJson(v));
      });
    }
    pagination = json['pagination'] != null
        ? Pagination.fromJson(json['pagination'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (atendances != null) {
      data['atendances'] = atendances!.map((v) => v.toJson()).toList();
    }
    if (pagination != null) {
      data['pagination'] = pagination!.toJson();
    }
    return data;
  }
}
