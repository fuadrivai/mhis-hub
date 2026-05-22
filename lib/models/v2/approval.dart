import 'package:fl_mhis_hr/models/v2/models.dart';
import 'package:jiffy/jiffy.dart';

class Approval {
  int? id;
  int? stepOrder;
  String? approvalMode;
  String? status;
  String? actionedDate;
  String? note;
  String? createdAt;
  String? updatedAt;
  bool? showAction = false;
  Employee? approver;
  ApprovalRequest? approvalRequest;
  List<ApprovalRequestData>? approvalRequestData;

  Approval(
      {this.id,
      this.stepOrder,
      this.approvalMode,
      this.status,
      this.actionedDate,
      this.note,
      this.createdAt,
      this.updatedAt,
      this.approver,
      this.showAction = false,
      this.approvalRequest,
      this.approvalRequestData});

  Approval.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    stepOrder = json['step_order'];
    approvalMode = json['approval_mode'];
    status = json['status'];
    actionedDate = json['actioned_date'];
    note = json['note'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    showAction = json['show_action'] ?? false;
    approver =
        json['approver'] != null ? Employee.fromJson(json['approver']) : null;
    if (json['approval_request_data'] != null) {
      approvalRequestData = <ApprovalRequestData>[];
      json['approval_request_data'].forEach((v) {
        approvalRequestData!.add(ApprovalRequestData.fromJson(v));
      });
    }
    if (json['approval_request'] != null) {
      approvalRequest = ApprovalRequest.fromJson(json['approval_request']);
    }
  }

  static String? formatDateTime(String? value) {
    final DateTime? parsed = ApprovalRequestData.parseDynamicDate(value);
    if (parsed == null) {
      return null;
    }

    return Jiffy.parseFromDateTime(parsed).format(pattern: 'dd MMMM yyyy');
  }
}
