class Employment {
  String? employeeId;
  int? companyId;
  int? organizationId;
  String? organizationName;
  int? jobPositionId;
  String? jobPosition;
  int? jobLevelId;
  String? jobLevel;
  int? employmentStatusId;
  String? employmentStatus;
  String? endDate;
  int? branchId;
  String? branch;
  String? joinDate;
  String? lengthOfService;
  String? grade;
  String? classes;
  int? approvalLine;
  String? approvalLineEmployeeId;
  String? status;
  String? resignDate;
  List<dynamic>? workingExperiences;
  String? nationalityCode;
  String? signDate;
  List<dynamic>? sbu;

  Employment(
      {this.employeeId,
      this.companyId,
      this.organizationId,
      this.organizationName,
      this.jobPositionId,
      this.jobPosition,
      this.jobLevelId,
      this.jobLevel,
      this.employmentStatusId,
      this.employmentStatus,
      this.endDate,
      this.branchId,
      this.branch,
      this.joinDate,
      this.lengthOfService,
      this.grade,
      this.classes,
      this.approvalLine,
      this.approvalLineEmployeeId,
      this.status,
      this.resignDate,
      this.workingExperiences,
      this.nationalityCode,
      this.signDate,
      this.sbu});

  Employment.fromJson(Map<String, dynamic> json) {
    employeeId = json['employee_id'];
    companyId = json['company_id'];
    organizationId = json['organization_id'];
    organizationName = json['organization_name'];
    jobPositionId = json['job_position_id'];
    jobPosition = json['job_position'];
    jobLevelId = json['job_level_id'];
    jobLevel = json['job_level'];
    employmentStatusId = json['employment_status_id'];
    employmentStatus = json['employment_status'];
    endDate = json['end_date'];
    branchId = json['branch_id'];
    branch = json['branch'];
    joinDate = json['join_date'];
    lengthOfService = json['length_of_service'];
    grade = json['grade'];
    classes = json['class'];
    approvalLine = json['approval_line'];
    approvalLineEmployeeId = json['approval_line_employee_id'];
    status = json['status'];
    resignDate = json['resign_date'];
    if (json['working_experiences'] != null) {
      workingExperiences = <Null>[];
      workingExperiences = json['working_experiences'];
    }
    nationalityCode = json['nationality_code'];
    signDate = json['sign_date'];
    if (json['sbu'] != null) {
      sbu = json['sbu'];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['employee_id'] = employeeId;
    data['company_id'] = companyId;
    data['organization_id'] = organizationId;
    data['organization_name'] = organizationName;
    data['job_position_id'] = jobPositionId;
    data['job_position'] = jobPosition;
    data['job_level_id'] = jobLevelId;
    data['job_level'] = jobLevel;
    data['employment_status_id'] = employmentStatusId;
    data['employment_status'] = employmentStatus;
    data['end_date'] = endDate;
    data['branch_id'] = branchId;
    data['branch'] = branch;
    data['join_date'] = joinDate;
    data['length_of_service'] = lengthOfService;
    data['grade'] = grade;
    data['class'] = classes;
    data['approval_line'] = approvalLine;
    data['approval_line_employee_id'] = approvalLineEmployeeId;
    data['status'] = status;
    data['resign_date'] = resignDate;
    if (workingExperiences != null) {
      data['working_experiences'] =
          workingExperiences!.map((v) => v.toJson()).toList();
    }
    data['nationality_code'] = nationalityCode;
    data['sign_date'] = signDate;
    if (sbu != null) {
      data['sbu'] = sbu!.map((v) => v.toJson()).toList();
    }
    return data;
  }

  List<Map<String, dynamic>> listForm() => [
        {"title": "Employee Id", "value": employeeId},
        {"title": "Barcode", "value": employeeId},
        {"title": "Branch", "value": branch},
        {"title": "Organization Name", "value": organizationName},
        {"title": "Job Position", "value": jobPosition},
        {"title": "Job Level", "value": jobLevel},
        {"title": "Employment Status", "value": status},
        {"title": "Join Date", "value": joinDate},
        {"title": "End Contract Date", "value": endDate},
        {"title": "Working Period", "value": lengthOfService}
      ];
}
