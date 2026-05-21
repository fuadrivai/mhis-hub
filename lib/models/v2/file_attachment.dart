import 'dart:io';

class FileAttachment {
  final int? id;
  final String fileName;
  final String filePath;
  final String? mimeType;
  final int fileSize;
  final File? file;

  FileAttachment({
    this.id,
    required this.fileName,
    required this.filePath,
    this.mimeType,
    required this.fileSize,
    this.file,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'file_name': fileName,
      'file_path': filePath,
      'mime_type': mimeType,
      'file_size': fileSize,
    };
  }

  factory FileAttachment.fromJson(Map<String, dynamic> json) {
    return FileAttachment(
      id: json['id'],
      fileName: json['file_name'],
      filePath: json['file_path'],
      mimeType: json['mime_type'],
      fileSize: json['file_size'],
    );
  }

  factory FileAttachment.fromFile(File file) {
    return FileAttachment(
      fileName: file.path.split('/').last,
      filePath: file.path,
      fileSize: file.lengthSync(),
      mimeType: _getMimeType(file.path),
      file: file,
    );
  }

  bool isValidSize() => fileSize <= 10240 * 1024; // 10MB

  @override
  String toString() =>
      'FileAttachment(id: $id, fileName: $fileName, fileSize: $fileSize)';
}

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
