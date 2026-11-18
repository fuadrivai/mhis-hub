String? visitorAttachmentError(String name, int size) {
  final extension = name.split('.').last.toLowerCase();
  if (!name.contains('.') ||
      !['pdf', 'jpg', 'jpeg', 'png'].contains(extension)) {
    return 'Only PDF, JPG, JPEG, and PNG files are allowed.';
  }
  if (size > 5 * 1024 * 1024) {
    return 'Attachment must be 5 MB or smaller.';
  }
  return null;
}
