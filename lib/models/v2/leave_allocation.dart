import 'package:fl_mhis_hr/models/v2/models.dart';

class LeaveAllocation {
  AcademicYear? academicYear;
  int? total;
  int? used;
  int? remaining;

  LeaveAllocation({this.academicYear, this.total, this.used, this.remaining});

  LeaveAllocation.fromJson(Map<String, dynamic> json) {
    academicYear = json['academicYear'] != null
        ? AcademicYear.fromJson(json['academicYear'])
        : null;
    total = json['total'];
    used = json['used'];
    remaining = json['remaining'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (academicYear != null) {
      data['academicYear'] = academicYear!.toJson();
    }
    data['total'] = total;
    data['used'] = used;
    data['remaining'] = remaining;
    return data;
  }
}
