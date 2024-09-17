import 'package:fl_mhis_hr/models/model.dart';

class ServerSideEmployee {
  List<EmployeeV3>? employees;
  Pagination? pagination;

  ServerSideEmployee({this.employees, this.pagination});

  ServerSideEmployee.fromJson(Map<String, dynamic> json) {
    if (json['employees'] != null) {
      employees = <EmployeeV3>[];
      json['employees'].forEach((v) {
        employees!.add(EmployeeV3.fromJson(v));
      });
    }
    pagination = json['pagination'] != null
        ? Pagination.fromJson(json['pagination'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (employees != null) {
      data['employees'] = employees!.map((v) => v.toJson()).toList();
    }
    if (pagination != null) {
      data['pagination'] = pagination!.toJson();
    }
    return data;
  }
}
