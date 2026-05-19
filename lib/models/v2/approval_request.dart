import 'package:fl_mhis_hr/models/v2/models.dart';

class ApprovalRequest {
  final int id;
  final String? note;
  final int? currentStep;
  final String? status;

  final Timeoff? type;
  final ApprovalRequestDataModel? data;
  final Employee? requester;
  final ApprovalRule? approvalRule;

  final List<ApprovalRequestAttachmentModel> attachments;
  final List<ApprovalModel> approvals;
  final List<ApprovalHistory> histories;

  ApprovalRequest({
    required this.id,
    this.note,
    this.currentStep,
    this.status,
    this.type,
    this.data,
    this.requester,
    this.approvalRule,
    this.attachments = const [],
    this.approvals = const [],
    this.histories = const [],
  });

  factory ApprovalRequest.fromJson(Map<String, dynamic> json) {
    return ApprovalRequest(
      id: _asInt(json['id']) ?? 0,
      note: json['note'] as String?,
      currentStep: _asInt(json['current_step']),
      status: json['status'] as String?,
      type: _mapOrNull(json['type'], Timeoff.fromJson),
      data: _mapOrNull(json['data'], ApprovalRequestDataModel.fromJson),
      requester: _mapOrNull(json['requester'], Employee.fromJson),
      approvalRule: _mapOrNull(json['approval_rule'], ApprovalRule.fromJson),
      attachments: _listMap(
        json['attachments'],
        ApprovalRequestAttachmentModel.fromJson,
      ),
      approvals: _listMap(json['approvals'], ApprovalModel.fromJson),
      histories: _listMap(json['histories'], ApprovalHistory.fromJson),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'note': note,
        'current_step': currentStep,
        'status': status,
        'type': type?.toJson(),
        'data': data?.toJson(),
        'requester': requester?.toJson(),
        'approval_rule': approvalRule?.toJson(),
        'attachments': attachments.map((e) => e.toJson()).toList(),
        'approvals': approvals.map((e) => e.toJson()).toList(),
        'histories': histories.map((e) => e.toJson()).toList(),
      };
}

class TimeOffTypeModel {
  final int id;
  final String? name;
  final bool? isActive;
  final Map<String, dynamic>? schema;
  final String? createdAt;
  final String? updatedAt;

  TimeOffTypeModel({
    required this.id,
    this.name,
    this.isActive,
    this.schema,
    this.createdAt,
    this.updatedAt,
  });

  factory TimeOffTypeModel.fromJson(Map<String, dynamic> json) {
    return TimeOffTypeModel(
      id: _asInt(json['id']) ?? 0,
      name: json['name'] as String?,
      isActive: json['is_active'] as bool?,
      schema: _asMap(json['schema']),
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'is_active': isActive,
        'schema': schema,
        'created_at': createdAt,
        'updated_at': updatedAt,
      };
}

class ApprovalRequestDataModel {
  final int id;
  final Map<String, dynamic> data;

  ApprovalRequestDataModel({
    required this.id,
    required this.data,
  });

  factory ApprovalRequestDataModel.fromJson(Map<String, dynamic> json) {
    return ApprovalRequestDataModel(
      id: json['id'],
      data: json['data'] as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'data': data,
      };
}

class EmployeeModel {
  final int id;
  final String? employeeCode;
  final String? createdAt;
  final String? updatedAt;

  final PersonalModel? personal;
  final EmploymentModel? employment;

  EmployeeModel({
    required this.id,
    this.employeeCode,
    this.createdAt,
    this.updatedAt,
    this.personal,
    this.employment,
  });

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    return EmployeeModel(
      id: _asInt(json['id']) ?? 0,
      employeeCode: json['employee_code'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      personal: _mapOrNull(json['personal'], PersonalModel.fromJson),
      employment: _mapOrNull(json['employment'], EmploymentModel.fromJson),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'employee_code': employeeCode,
        'created_at': createdAt,
        'updated_at': updatedAt,
        'personal': personal?.toJson(),
        'employment': employment?.toJson(),
      };
}

class PersonalModel {
  final int id;
  final String? fullname;
  final String? birthDate;
  final int? gender;
  final String? phone;
  final String? email;
  final String? address;
  final String? createdAt;
  final String? updatedAt;
  final NamedEntityModel? religion;

  PersonalModel({
    required this.id,
    this.fullname,
    this.birthDate,
    this.gender,
    this.phone,
    this.email,
    this.address,
    this.createdAt,
    this.updatedAt,
    this.religion,
  });

  factory PersonalModel.fromJson(Map<String, dynamic> json) {
    return PersonalModel(
      id: _asInt(json['id']) ?? 0,
      fullname: json['fullname'] as String?,
      birthDate: json['birth_date'] as String?,
      gender: _asInt(json['gender']),
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      address: json['address'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      religion: _mapOrNull(json['religion'], NamedEntityModel.fromJson),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'fullname': fullname,
        'birth_date': birthDate,
        'gender': gender,
        'phone': phone,
        'email': email,
        'address': address,
        'created_at': createdAt,
        'updated_at': updatedAt,
        'religion': religion?.toJson(),
      };
}

class EmploymentModel {
  final int id;
  final int? employeeId;
  final String? joinDate;
  final String? status;
  final int? branchId;
  final int? organizationId;
  final int? positionId;
  final int? jobLevelId;
  final String? createdAt;
  final String? updatedAt;

  EmploymentModel({
    required this.id,
    this.employeeId,
    this.joinDate,
    this.status,
    this.branchId,
    this.organizationId,
    this.positionId,
    this.jobLevelId,
    this.createdAt,
    this.updatedAt,
  });

  factory EmploymentModel.fromJson(Map<String, dynamic> json) {
    return EmploymentModel(
      id: _asInt(json['id']) ?? 0,
      employeeId: _asInt(json['employee_id']),
      joinDate: json['join_date'] as String?,
      status: json['status'] as String?,
      branchId: _asInt(json['branch_id']),
      organizationId: _asInt(json['organization_id']),
      positionId: _asInt(json['position_id']),
      jobLevelId: _asInt(json['job_level_id']),
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'employee_id': employeeId,
        'join_date': joinDate,
        'status': status,
        'branch_id': branchId,
        'organization_id': organizationId,
        'position_id': positionId,
        'job_level_id': jobLevelId,
        'created_at': createdAt,
        'updated_at': updatedAt,
      };
}

class ApprovalRequestAttachmentModel {
  final int id;
  final int? approvalRequestId;
  final String? fieldName;
  final String? fileName;
  final String? filePath;
  final String? mimeType;
  final int? fileSize;
  final String? createdAt;
  final String? updatedAt;

  ApprovalRequestAttachmentModel({
    required this.id,
    this.approvalRequestId,
    this.fieldName,
    this.fileName,
    this.filePath,
    this.mimeType,
    this.fileSize,
    this.createdAt,
    this.updatedAt,
  });

  factory ApprovalRequestAttachmentModel.fromJson(Map<String, dynamic> json) {
    return ApprovalRequestAttachmentModel(
      id: _asInt(json['id']) ?? 0,
      approvalRequestId: _asInt(json['approval_request_id']),
      fieldName: json['field_name'] as String?,
      fileName: json['file_name'] as String?,
      filePath: json['file_path'] as String?,
      mimeType: json['mime_type'] as String?,
      fileSize: _asInt(json['file_size']),
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'approval_request_id': approvalRequestId,
        'field_name': fieldName,
        'file_name': fileName,
        'file_path': filePath,
        'mime_type': mimeType,
        'file_size': fileSize,
        'created_at': createdAt,
        'updated_at': updatedAt,
      };
}

class ApprovalModel {
  final int id;
  final int? stepOrder;
  final String? approvalMode;
  final String? status;
  final String? note;
  final String? approvedAt;
  final String? createdAt;
  final String? updatedAt;
  final Employee? approver;

  ApprovalModel({
    required this.id,
    this.stepOrder,
    this.approvalMode,
    this.status,
    this.note,
    this.approvedAt,
    this.createdAt,
    this.updatedAt,
    this.approver,
  });

  factory ApprovalModel.fromJson(Map<String, dynamic> json) {
    return ApprovalModel(
      id: _asInt(json['id']) ?? 0,
      stepOrder: _asInt(json['step_order']),
      approvalMode: json['approval_mode'] as String?,
      status: json['status'] as String?,
      note: json['note'] as String?,
      approvedAt: json['approved_at'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      approver: _mapOrNull(json['approver'], Employee.fromJson),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'step_order': stepOrder,
        'approval_mode': approvalMode,
        'status': status,
        'note': note,
        'approved_at': approvedAt,
        'created_at': createdAt,
        'updated_at': updatedAt,
        'approver': approver?.toJson(),
      };
}

class NamedEntityModel {
  final int id;
  final String? name;

  NamedEntityModel({required this.id, this.name});

  factory NamedEntityModel.fromJson(Map<String, dynamic> json) {
    return NamedEntityModel(
      id: _asInt(json['id']) ?? 0,
      name: json['name'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      };
}

// ---------- Helpers ----------
int? _asInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

Map<String, dynamic>? _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return value.cast<String, dynamic>();
  return null;
}

T? _mapOrNull<T>(
  dynamic value,
  T Function(Map<String, dynamic>) parser,
) {
  final m = _asMap(value);
  if (m == null) return null;
  return parser(m);
}

List<T> _listMap<T>(
  dynamic value,
  T Function(Map<String, dynamic>) parser,
) {
  if (value is! List) return const [];
  return value
      .whereType<Map>()
      .map((e) => parser(e.cast<String, dynamic>()))
      .toList();
}
