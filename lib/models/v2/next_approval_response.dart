import 'package:fl_mhis_hr/models/v2/approval.dart';

class NextApprovalResponse {
  final Approval? data;

  const NextApprovalResponse({this.data});

  factory NextApprovalResponse.fromJson(Map<String, dynamic> json) {
    final raw = json['data'];
    return NextApprovalResponse(
      data: raw is Map<String, dynamic> && raw.isNotEmpty
          ? Approval.fromJson(raw)
          : null,
    );
  }
}
