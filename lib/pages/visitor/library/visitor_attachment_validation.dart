String? visitorAttachmentError(String name, int size) {
  final extension = name.split('.').last.toLowerCase();
  if (!name.contains('.') ||
      !['jpg', 'jpeg', 'png', 'webp'].contains(extension)) {
    return 'Only JPG, JPEG, PNG, and WEBP images are allowed.';
  }
  if (size > 5 * 1024 * 1024) {
    return 'Attachment must be 5 MB or smaller.';
  }
  return null;
}
