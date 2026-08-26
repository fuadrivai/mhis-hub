import 'package:fl_mhis_hr/models/model.dart';
import 'package:fl_mhis_hr/models/v2/models.dart';

class ServerSideAttendance {
  List<ApprovalRequest>? requests;
  Pagination? pagination;

  ServerSideAttendance({this.requests, this.pagination});

  ServerSideAttendance.fromJson(Map<String, dynamic> json) {
    if (json['requests'] != null) {
      requests = <ApprovalRequest>[];
      json['requests'].forEach((v) {
        requests!.add(ApprovalRequest.fromJson(v));
      });
    }
    pagination = json['pagination'] != null
        ? Pagination.fromJson(json['pagination'])
        : null;
  }
}
