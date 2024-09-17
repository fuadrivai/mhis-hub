class EmployeeV3 {
  int? userId;
  String? ssoId;
  String? employeeId;
  String? firstName;
  String? lastName;
  String? fullName;
  int? branchId;
  String? branch;
  int? organizationId;
  String? organizationName;
  int? companyId;
  int? jobPositionId;
  String? employmentStatus;
  String? joinDate;
  String? endDate;
  String? resignDate;
  String? grade;
  String? classes;
  String? barcode;
  String? email;
  String? birthPlace;
  String? birthDate;
  String? address;
  String? mobilePhone;
  String? religion;
  String? postalCode;
  String? identityType;
  String? identityNumber;
  String? gender;
  String? avatar;
  String? phone;
  String? bloodType;
  String? nationalityCode;
  String? submitResignDate;
  String? maritalStatus;
  String? createdAt;
  String? updatedAt;

  EmployeeV3(
      {this.userId,
      this.ssoId,
      this.employeeId,
      this.firstName,
      this.lastName,
      this.fullName,
      this.branchId,
      this.branch,
      this.organizationId,
      this.organizationName,
      this.companyId,
      this.jobPositionId,
      this.employmentStatus,
      this.joinDate,
      this.endDate,
      this.resignDate,
      this.grade,
      this.classes,
      this.barcode,
      this.email,
      this.birthPlace,
      this.birthDate,
      this.address,
      this.mobilePhone,
      this.religion,
      this.postalCode,
      this.identityType,
      this.identityNumber,
      this.gender,
      this.avatar,
      this.phone,
      this.bloodType,
      this.nationalityCode,
      this.submitResignDate,
      this.maritalStatus,
      this.createdAt,
      this.updatedAt});

  EmployeeV3.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    ssoId = json['sso_id'];
    employeeId = json['employee_id'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    fullName = "$firstName $lastName";
    branchId = json['branch_id'];
    branch = json['branch'];
    organizationId = json['organization_id'];
    organizationName = json['organization_name'];
    companyId = json['company_id'];
    jobPositionId = json['job_position_id'];
    employmentStatus = json['employment_status'];
    joinDate = json['join_date'];
    endDate = json['end_date'];
    resignDate = json['resign_date'];
    grade = json['grade'];
    classes = json['class'];
    barcode = json['barcode'];
    email = json['email'];
    birthPlace = json['birth_place'];
    birthDate = json['birth_date'];
    address = json['address'];
    mobilePhone = json['mobile_phone'];
    religion = json['religion'];
    postalCode = json['postal_code'];
    identityType = json['identity_type'];
    identityNumber = json['identity_number'];
    gender = json['gender'];
    avatar = json['avatar'];
    phone = json['phone'];
    bloodType = json['blood_type'];
    nationalityCode = json['nationality_code'];
    submitResignDate = json['submit_resign_date'];
    maritalStatus = json['marital_status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['user_id'] = userId;
    data['sso_id'] = ssoId;
    data['employee_id'] = employeeId;
    data['first_name'] = firstName;
    data['last_name'] = lastName;
    data['branch_id'] = branchId;
    data['branch'] = branch;
    data['organization_id'] = organizationId;
    data['organization_name'] = organizationName;
    data['company_id'] = companyId;
    data['job_position_id'] = jobPositionId;
    data['employment_status'] = employmentStatus;
    data['join_date'] = joinDate;
    data['end_date'] = endDate;
    data['resign_date'] = resignDate;
    data['grade'] = grade;
    data['class'] = classes;
    data['barcode'] = barcode;
    data['email'] = email;
    data['birth_place'] = birthPlace;
    data['birth_date'] = birthDate;
    data['address'] = address;
    data['mobile_phone'] = mobilePhone;
    data['religion'] = religion;
    data['postal_code'] = postalCode;
    data['identity_type'] = identityType;
    data['identity_number'] = identityNumber;
    data['gender'] = gender;
    data['avatar'] = avatar;
    data['phone'] = phone;
    data['blood_type'] = bloodType;
    data['nationality_code'] = nationalityCode;
    data['submit_resign_date'] = submitResignDate;
    data['marital_status'] = maritalStatus;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}
