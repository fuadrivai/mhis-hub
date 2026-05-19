import 'package:fl_mhis_hr/models/v2/models.dart';

class ApprovalHistory {
  final int id;
  final String? action;
  final int? stepOrder;
  final String? note;
  final String? createdAt;
  final String? updatedAt;
  final Employee? approver;

  ApprovalHistory({
    required this.id,
    this.action,
    this.stepOrder,
    this.note,
    this.createdAt,
    this.updatedAt,
    this.approver,
  });

  factory ApprovalHistory.fromJson(Map<String, dynamic> json) {
    return ApprovalHistory(
      id: json['id'],
      action: json['action'] as String?,
      stepOrder: json['step_order'],
      note: json['note'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      approver:
          json['approver'] != null ? Employee.fromJson(json['approver']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'action': action,
        'step_order': stepOrder,
        'note': note,
        'created_at': createdAt,
        'updated_at': updatedAt,
        'approver': approver?.toJson(),
      };
}
