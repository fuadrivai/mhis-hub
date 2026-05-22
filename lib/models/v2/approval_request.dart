import 'package:fl_mhis_hr/models/v2/models.dart';
import 'package:jiffy/jiffy.dart';

class ApprovalRequest {
  int? id;
  int? currentStep;
  String? status;
  String? note;
  Timeoff? type;
  ApprovalRequestData? data;
  List<Approval>? approvals;
  Employee? requester;
  ApprovalRule? approvalRule;
  List<FileAttachment>? attachments;
  List<ApprovalHistory>? histories;
  bool showCancel = false;
  String? createdAt;
  String? updatedAt;

  ApprovalRequest(
      {this.id,
      this.currentStep,
      this.status,
      this.note,
      this.type,
      this.data,
      this.approvals,
      this.requester,
      this.approvalRule,
      this.attachments,
      this.histories,
      this.createdAt,
      this.updatedAt,
      this.showCancel = false});

  ApprovalRequest.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    currentStep = json['current_step'];
    status = json['status'];
    note = json['note'];
    type = json['type'] != null ? Timeoff.fromJson(json['type']) : null;
    data = json['data'] != null
        ? ApprovalRequestData.fromJson(json['data'])
        : null;
    if (json['approvals'] != null) {
      approvals = <Approval>[];
      json['approvals'].forEach((v) {
        approvals!.add(Approval.fromJson(v));
      });
    }
    showCancel = json['show_cancel'] ?? false;
    requester =
        json['requester'] != null ? Employee.fromJson(json['requester']) : null;
    approvalRule = json['approval_rule'] != null
        ? ApprovalRule.fromJson(json['approval_rule'])
        : null;
    if (json['attachments'] != null) {
      attachments = <FileAttachment>[];
      json['attachments'].forEach((v) {
        attachments!.add(FileAttachment.fromJson(v));
      });
    }
    if (json['histories'] != null) {
      histories = <ApprovalHistory>[];
      json['histories'].forEach((v) {
        histories!.add(ApprovalHistory.fromJson(v));
      });
    }
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }
}

class ApprovalRequestData {
  int? id;
  Map<String, dynamic>? payload;

  ApprovalRequestData({this.id, this.payload});

  ApprovalRequestData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    payload = json['payload'] != null
        ? Map<String, dynamic>.from(json['payload'])
        : null;
  }

  static String formatRequestDate(ApprovalRequest request) {
    final dynamic rawDate = resolveRequestDateValue(request);
    final DateTime? parsedDate = parseDynamicDate(rawDate);

    if (parsedDate == null) {
      return "--";
    }

    return Jiffy.parseFromDateTime(parsedDate).format(pattern: "dd MMMM yyyy");
  }

  static dynamic resolveRequestDateValue(ApprovalRequest request) {
    final Map<String, dynamic>? payload = request.data?.payload;
    if (payload == null || payload.isEmpty) {
      return null;
    }

    final List<TimeoffSchema> schema =
        request.type?.schema ?? <TimeoffSchema>[];

    final Iterable<String> schemaDateKeys = schema
        .where((field) => looksLikeDateField(field))
        .map((field) => field.name?.trim() ?? "")
        .where((name) => name.isNotEmpty);

    final Iterable<String> schemaKeys = schema
        .map((field) => field.name?.trim() ?? "")
        .where((name) => name.isNotEmpty);

    for (final String key in <String>{
      ...schemaDateKeys,
      ...schemaKeys,
      'start_date',
      'startDate',
      'date',
    }) {
      if (!payload.containsKey(key)) {
        continue;
      }

      final dynamic value = payload[key];
      if (parseDynamicDate(value) != null) {
        return value;
      }
    }

    for (final dynamic value in payload.values) {
      if (parseDynamicDate(value) != null) {
        return value;
      }
    }

    return null;
  }

  static bool looksLikeDateField(TimeoffSchema field) {
    final String type = (field.type ?? '').toLowerCase();
    final String name = (field.name ?? '').toLowerCase();
    final String label = (field.label ?? '').toLowerCase();

    if (type.contains('date') || type.contains('datetime')) {
      return true;
    }

    return name.contains('date') ||
        name.contains('start') ||
        name.contains('end') ||
        label.contains('date') ||
        label.contains('start') ||
        label.contains('end');
  }

  static DateTime? parseDynamicDate(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is DateTime) {
      return value.toLocal();
    }

    if (value is int) {
      final int milliseconds = value > 100000000000 ? value : value * 1000;
      return DateTime.fromMillisecondsSinceEpoch(milliseconds).toLocal();
    }

    if (value is String) {
      final String text = value.trim();
      if (text.isEmpty) {
        return null;
      }

      final int? asEpoch = int.tryParse(text);
      if (asEpoch != null) {
        final int milliseconds =
            asEpoch > 100000000000 ? asEpoch : asEpoch * 1000;
        return DateTime.fromMillisecondsSinceEpoch(milliseconds).toLocal();
      }

      try {
        return DateTime.parse(text).toLocal();
      } catch (_) {
        try {
          return Jiffy.parse(text).dateTime.toLocal();
        } catch (_) {
          return null;
        }
      }
    }

    if (value is Map) {
      final List<MapEntry<dynamic, dynamic>> entries = value.entries.toList();

      // Prefer keys that look like date fields, then fallback to all values.
      for (final MapEntry<dynamic, dynamic> entry in entries) {
        final String key = entry.key.toString().toLowerCase();
        if (!looksLikeDateKey(key)) {
          continue;
        }

        final DateTime? nestedDate = parseDynamicDate(entry.value);
        if (nestedDate != null) {
          return nestedDate;
        }
      }

      for (final MapEntry<dynamic, dynamic> entry in entries) {
        final DateTime? nestedDate = parseDynamicDate(entry.value);
        if (nestedDate != null) {
          return nestedDate;
        }
      }

      return null;
    }

    if (value is Iterable) {
      for (final dynamic item in value) {
        final DateTime? nestedDate = parseDynamicDate(item);
        if (nestedDate != null) {
          return nestedDate;
        }
      }

      return null;
    }

    return null;
  }

  static bool looksLikeDateKey(String key) {
    return key.contains('date') ||
        key.contains('start') ||
        key.contains('end') ||
        key.contains('from') ||
        key.contains('to') ||
        key.contains('at') ||
        key.contains('time');
  }
}
