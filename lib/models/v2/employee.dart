import 'package:fl_mhis_hr/models/v2/models.dart';

class Employee {
  int? id;
  String? idTalenta;
  String? createdAt;
  String? updatedAt;
  int? scheduleId;
  Person? approval;
  int? payrolInfoId;
  int? locationId;
  Person? personal;
  Employment? employment;
  ActiveSchedule? activeSchedule;
  User? user;

  Employee({
    this.id,
    this.idTalenta,
    this.createdAt,
    this.updatedAt,
    this.scheduleId,
    this.approval,
    this.payrolInfoId,
    this.locationId,
    this.personal,
    this.employment,
    this.user,
    this.activeSchedule,
  });

  Employee.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    idTalenta = json['id_talenta'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    scheduleId = json['schedule_id'];
    approval =
        json['approval'] != null ? Person.fromJson(json['approval']) : null;
    activeSchedule = json['active_schedule'] != null
        ? ActiveSchedule.fromJson(json['active_schedule'])
        : null;
    payrolInfoId = json['payrol_info_id'];
    locationId = json['location_id'];
    personal =
        json['personal'] != null ? Person.fromJson(json['personal']) : null;
    user = json['user'] != null ? User.fromJson(json['user']) : null;
    employment = json['employment'] != null
        ? Employment.fromJson(json['employment'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['id_talenta'] = idTalenta;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['schedule_id'] = scheduleId;
    data['approval'] = approval;
    data['payrol_info_id'] = payrolInfoId;
    data['location_id'] = locationId;
    if (personal != null) {
      data['personal'] = personal!.toJson();
    }
    if (employment != null) {
      data['employment'] = employment!.toJson();
    }
    if (user != null) {
      data['user'] = user!.toJson();
    }
    if (activeSchedule != null) {
      data['active_schedule'] = activeSchedule!.toJson();
    }
    return data;
  }
}
