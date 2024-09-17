import 'package:fl_mhis_hr/models/model.dart';

class Employee {
  int? userId;
  String? ssoId;
  String? createdAt;
  String? updatedAt;
  Person? person;
  Family? family;
  Education? education;
  Employment? employment;
  PayrollInfo? payrollInfo;
  List<dynamic>? customField;
  AccessRole? accessRole;

  Employee({
    this.userId,
    this.ssoId,
    this.createdAt,
    this.updatedAt,
    this.person,
    this.family,
    this.education,
    this.employment,
    this.payrollInfo,
    this.customField,
    this.accessRole,
  });

  Employee.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    ssoId = json['sso_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    person =
        json['personal'] != null ? Person.fromJson(json['personal']) : null;
    family = json['family'] != null ? Family.fromJson(json['family']) : null;
    education = json['education'] != null
        ? Education.fromJson(json['education'])
        : null;
    employment = json['employment'] != null
        ? Employment.fromJson(json['employment'])
        : null;
    payrollInfo = json['payroll_info'] != null
        ? PayrollInfo.fromJson(json['payroll_info'])
        : null;
    if (json['custom_field'] != null) {
      customField = json['custom_field'];
    }
    accessRole = json['access_role'] != null
        ? AccessRole.fromJson(json['access_role'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['user_id'] = userId;
    data['sso_id'] = ssoId;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    if (person != null) {
      data['personal'] = person!.toJson();
    }
    if (family != null) {
      data['family'] = family!.toJson();
    }
    if (education != null) {
      data['education'] = education!.toJson();
    }
    if (employment != null) {
      data['employment'] = employment!.toJson();
    }
    if (payrollInfo != null) {
      data['payroll_info'] = payrollInfo!.toJson();
    }
    if (customField != null) {
      data['custom_field'] = customField!.map((v) => v.toJson()).toList();
    }
    if (accessRole != null) {
      data['access_role'] = accessRole!.toJson();
    }
    return data;
  }
}
