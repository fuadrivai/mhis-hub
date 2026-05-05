import 'package:fl_mhis_hr/models/v2/models.dart';

class Employment {
  int? id;
  String? employeeId;
  String? organizationName;
  String? jobPositionName;
  String? approvalLine;
  String? jobLevelName;
  String? branchName;
  String? employmentStatus;
  String? joinDate;
  String? endDate;
  String? resignDate;
  String? signDate;
  int? status;
  String? nationalityCode;
  String? createdAt;
  String? updatedAt;
  String? companyId;
  String? barcode;
  String? approvalLineName;
  Branch? branch;
  JobLevel? jobLevel;
  Organization? organization;
  JobPosition? jobPosition;

  Employment({
    this.id,
    this.employeeId,
    this.organizationName,
    this.jobPositionName,
    this.approvalLine,
    this.jobLevelName,
    this.branchName,
    this.employmentStatus,
    this.joinDate,
    this.endDate,
    this.resignDate,
    this.signDate,
    this.status,
    this.nationalityCode,
    this.createdAt,
    this.updatedAt,
    this.companyId,
    this.barcode,
    this.approvalLineName,
    this.branch,
    this.jobLevel,
    this.organization,
    this.jobPosition,
  });

  Employment.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    employeeId = json['employee_id'];
    organizationName = json['organization_name'];
    jobPositionName = json['job_position_name'];
    approvalLine = json['approval_line'];
    jobLevelName = json['job_level_name'];
    branchName = json['branch_name'];
    employmentStatus = json['employment_status'];
    joinDate = json['join_date'];
    endDate = json['end_date'];
    resignDate = json['resign_date'];
    signDate = json['sign_date'];
    status = json['status'];
    nationalityCode = json['nationality_code'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    companyId = json['company_id'];
    barcode = json['barcode'];
    approvalLineName = json['approval_line_name'];
    branch = json['branch'] != null ? Branch.fromJson(json['branch']) : null;
    jobLevel =
        json['job_level'] != null ? JobLevel.fromJson(json['job_level']) : null;
    organization = json['organization'] != null
        ? Organization.fromJson(json['organization'])
        : null;
    jobPosition = json['job_position'] != null
        ? JobPosition.fromJson(json['job_position'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['employee_id'] = employeeId;
    data['organization_name'] = organizationName;
    data['job_position_name'] = jobPositionName;
    data['approval_line'] = approvalLine;
    data['job_level_name'] = jobLevelName;
    data['branch_name'] = branchName;
    data['employment_status'] = employmentStatus;
    data['join_date'] = joinDate;
    data['end_date'] = endDate;
    data['resign_date'] = resignDate;
    data['sign_date'] = signDate;
    data['status'] = status;
    data['nationality_code'] = nationalityCode;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['company_id'] = companyId;
    data['barcode'] = barcode;
    data['approval_line_name'] = approvalLineName;
    if (branch != null) {
      data['branch'] = branch!.toJson();
    }
    if (jobLevel != null) {
      data['job_level'] = jobLevel!.toJson();
    }
    if (organization != null) {
      data['organization'] = organization!.toJson();
    }
    if (jobPosition != null) {
      data['job_position'] = jobPosition!.toJson();
    }
    return data;
  }
}
