import 'package:fl_mhis_hr/models/v2/models.dart';

class ApprovalStep {
  final int id;
  final int? stepOrder;
  final String? name;
  final String? approvalMode;
  final Employee? approverEmployee;

  ApprovalStep({
    required this.id,
    this.stepOrder,
    this.name,
    this.approvalMode,
    this.approverEmployee,
  });

  factory ApprovalStep.fromJson(Map<String, dynamic> json) {
    return ApprovalStep(
      id: json['id'],
      stepOrder: json['step_order'],
      name: json['name'] as String?,
      approvalMode: json['approval_mode'] as String?,
      approverEmployee: json['approverEmployee'] != null
          ? Employee.fromJson(json['approverEmployee'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'step_order': stepOrder,
        'name': name,
        'approval_mode': approvalMode,
        'approverEmployee': approverEmployee?.toJson(),
      };
}
