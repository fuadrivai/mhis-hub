import 'dart:io';

/// Main model for Approval Request data
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

  /// Convert model to JSON for API request
  Map<String, dynamic> toJson() {
    return {
      'requester_employee_id': requesterEmployeeId,
      'timeoff_id': timeoffId,
      'note': note,
      'dynamic_fields': dynamicFields,
    };
  }

  /// Create model from JSON response
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

/// Model for file attachments
class FileAttachment {
  final String? id;
  final String fileName;
  final String filePath;
  final String? mimeType;
  final int fileSize;
  final File? file; // For local files before upload

  FileAttachment({
    this.id,
    required this.fileName,
    required this.filePath,
    this.mimeType,
    required this.fileSize,
    this.file,
  });

  /// Convert to JSON for API response
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'file_name': fileName,
      'file_path': filePath,
      'mime_type': mimeType,
      'file_size': fileSize,
    };
  }

  /// Create from JSON response
  factory FileAttachment.fromJson(Map<String, dynamic> json) {
    return FileAttachment(
      id: json['id'] as String?,
      fileName: json['file_name'] as String? ?? json['fileName'] as String,
      filePath: json['file_path'] as String? ?? json['filePath'] as String,
      mimeType: json['mime_type'] as String? ?? json['mimeType'] as String?,
      fileSize: json['file_size'] as int? ?? json['fileSize'] as int? ?? 0,
    );
  }

  /// Create from local File
  factory FileAttachment.fromFile(File file) {
    return FileAttachment(
      fileName: file.path.split('/').last,
      filePath: file.path,
      fileSize: file.lengthSync(),
      mimeType: _getMimeType(file.path),
      file: file,
    );
  }

  /// Validate file size (max 10MB as per Laravel validation)
  bool isValidSize() => fileSize <= 10240 * 1024; // 10MB

  @override
  String toString() =>
      'FileAttachment(id: $id, fileName: $fileName, fileSize: $fileSize)';
}

/// Model for dynamic fields
class DynamicField {
  final String key;
  final dynamic value;
  final String? type; // e.g., 'string', 'number', 'date', 'boolean'

  DynamicField({
    required this.key,
    required this.value,
    this.type,
  });

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'value': value,
      'type': type,
    };
  }

  factory DynamicField.fromJson(Map<String, dynamic> json) {
    return DynamicField(
      key: json['key'] as String,
      value: json['value'],
      type: json['type'] as String?,
    );
  }
}

/// Request builder for creating approval requests
class RequestBuilder {
  late int _requesterEmployeeId;
  late int _timeoffId;
  String? _note;
  Map<String, dynamic>? _dynamicFields;
  final List<FileAttachment> _attachments = [];

  RequestBuilder requesterEmployeeId(int id) {
    _requesterEmployeeId = id;
    return this;
  }

  RequestBuilder timeoffId(int id) {
    _timeoffId = id;
    return this;
  }

  RequestBuilder note(String? note) {
    _note = note;
    return this;
  }

  RequestBuilder dynamicFields(Map<String, dynamic>? fields) {
    _dynamicFields = fields;
    return this;
  }

  RequestBuilder addAttachment(FileAttachment attachment) {
    if (attachment.isValidSize()) {
      _attachments.add(attachment);
    }
    return this;
  }

  RequestBuilder addAttachments(List<FileAttachment> attachments) {
    _attachments.addAll(
      attachments.where((a) => a.isValidSize()),
    );
    return this;
  }

  Request build() {
    return Request(
      requesterEmployeeId: _requesterEmployeeId,
      timeoffId: _timeoffId,
      note: _note,
      dynamicFields: _dynamicFields,
      attachments: _attachments.isEmpty ? null : _attachments,
    );
  }
}

/// Utility function to determine MIME type from file extension
String? _getMimeType(String filePath) {
  final ext = filePath.split('.').last.toLowerCase();
  const mimeTypes = {
    'pdf': 'application/pdf',
    'doc': 'application/msword',
    'docx':
        'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    'xls': 'application/vnd.ms-excel',
    'xlsx': 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    'jpg': 'image/jpeg',
    'jpeg': 'image/jpeg',
    'png': 'image/png',
    'gif': 'image/gif',
    'txt': 'text/plain',
  };
  return mimeTypes[ext];
}
