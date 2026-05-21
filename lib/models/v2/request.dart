import 'package:fl_mhis_hr/models/v2/models.dart';

class Request {
  final int requesterEmployeeId;
  final int timeoffId;
  final String? note;
  final Map<String, dynamic>? dynamicFields;
  final List<FileAttachment>? attachments;

  Request({
    required this.requesterEmployeeId,
    required this.timeoffId,
    this.note,
    this.dynamicFields,
    this.attachments,
  });

  Map<String, dynamic> toJson() {
    return {
      'requester_employee_id': requesterEmployeeId,
      'timeoff_id': timeoffId,
      'note': note,
      'dynamic_fields': dynamicFields,
      'attachments':
          attachments?.map((attachment) => attachment.toJson()).toList(),
    };
  }

  factory Request.fromJson(Map<String, dynamic> json) {
    return Request(
      requesterEmployeeId: json['requester_employee_id'] as int,
      timeoffId: json['timeoff_id'] as int,
      note: json['note'] as String?,
      dynamicFields: json['dynamic_fields'] as Map<String, dynamic>?,
      attachments: (json['attachments'] as List?)
          ?.map((item) => FileAttachment.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  String toString() => '''Request(
    requesterEmployeeId: $requesterEmployeeId,
    timeoffId: $timeoffId,
    note: $note,
    dynamicFields: $dynamicFields,
    attachments: $attachments
  )''';
}
