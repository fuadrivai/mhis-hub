String visitorDateParameter(DateTime dateTime) {
  final year = dateTime.year.toString().padLeft(4, '0');
  final month = dateTime.month.toString().padLeft(2, '0');
  final day = dateTime.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}

String visitorDateTimeParameter(DateTime dateTime) {
  final hour = dateTime.hour.toString().padLeft(2, '0');
  final minute = dateTime.minute.toString().padLeft(2, '0');
  final second = dateTime.second.toString().padLeft(2, '0');
  final offset = dateTime.timeZoneOffset;
  final sign = offset.isNegative ? '-' : '+';
  final absoluteMinutes = offset.inMinutes.abs();
  final offsetHour = (absoluteMinutes ~/ 60).toString().padLeft(2, '0');
  final offsetMinute = (absoluteMinutes % 60).toString().padLeft(2, '0');
  return '${visitorDateParameter(dateTime)}T$hour:$minute:$second'
      '$sign$offsetHour:$offsetMinute';
}

DateTime? visitorJakartaDateTime(String value) {
  final dateTime = DateTime.tryParse(value);
  if (dateTime == null) return null;

  final hasTimezone = RegExp(r'(?:[zZ]|[+-]\d{2}:?\d{2})$').hasMatch(value);
  if (!hasTimezone) {
    return DateTime.utc(
      dateTime.year,
      dateTime.month,
      dateTime.day,
      dateTime.hour,
      dateTime.minute,
      dateTime.second,
      dateTime.millisecond,
      dateTime.microsecond,
    );
  }

  // Keep the display in WIB regardless of the device's configured timezone.
  return dateTime.toUtc().add(const Duration(hours: 7));
}
