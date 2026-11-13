import 'dart:typed_data';

import 'package:fl_mhis_hr/models/v2/branch.dart';
import 'package:fl_mhis_hr/models/v2/job_level.dart';
import 'package:fl_mhis_hr/models/v2/job_position.dart';

class VisitorPage<T> {
  const VisitorPage({
    required this.data,
    required this.page,
    required this.perPage,
    required this.total,
  });

  final List<T> data;
  final int page;
  final int perPage;
  final int total;
  bool get hasMore => page * perPage < total;
}

class VisitorOption {
  const VisitorOption({
    required this.id,
    required this.name,
    this.requiresApproval = false,
    this.requiresAdditionalInfo = false,
  });

  factory VisitorOption.fromJson(Map<String, dynamic> json) => VisitorOption(
        id: json['id'] as int,
        name: json['name'] as String,
        requiresApproval: json['requires_approval'] == true,
        requiresAdditionalInfo: json['requires_additional_info'] == true,
      );

  final int id;
  final String name;
  final bool requiresApproval;
  final bool requiresAdditionalInfo;
}

class VisitorFormOptions {
  const VisitorFormOptions({
    required this.branches,
    required this.categories,
    required this.purposes,
    this.defaultBranchId,
    this.defaultHostId,
  });

  factory VisitorFormOptions.fromJson(Map<String, dynamic> json) {
    List<VisitorOption> options(String key) => (json[key] as List)
        .map((item) => VisitorOption.fromJson(item as Map<String, dynamic>))
        .toList();
    return VisitorFormOptions(
      branches: options('branches'),
      categories: options('categories'),
      purposes: options('purposes'),
      defaultBranchId: json['default_branch_id'] as int?,
      defaultHostId: json['default_host_employee_id'] as int?,
    );
  }

  final List<VisitorOption> branches;
  final List<VisitorOption> categories;
  final List<VisitorOption> purposes;
  final int? defaultBranchId;
  final int? defaultHostId;
}

class VisitorHostFilters {
  const VisitorHostFilters({
    required this.branches,
    required this.levels,
    required this.positions,
  });

  final List<Branch> branches;
  final List<JobLevel> levels;
  final List<JobPosition> positions;
}

class VisitorHost {
  const VisitorHost({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.avatar,
    this.branch,
    this.organization,
    this.level,
    this.position,
  });

  factory VisitorHost.fromJson(Map<String, dynamic> json) {
    final personal = json['personal'] is Map<String, dynamic>
        ? json['personal'] as Map<String, dynamic>
        : const <String, dynamic>{};
    final employment = json['employment'] is Map<String, dynamic>
        ? json['employment'] as Map<String, dynamic>
        : const <String, dynamic>{};
    String? value(String key, String nestedKey) {
      final raw = json[key] ?? employment[key];
      if (raw is String) return raw;
      if (raw is Map<String, dynamic>) return raw['name'] as String?;
      final nested = json[nestedKey] ?? employment[nestedKey];
      if (nested is String) return nested;
      if (nested is Map<String, dynamic>) return nested['name'] as String?;
      return null;
    }

    return VisitorHost(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String? ?? personal['email'] as String?,
      phone: json['phone'] as String? ??
          json['mobile_phone'] as String? ??
          personal['mobile_phone'] as String?,
      avatar: json['avatar'] as String? ??
          personal['avatar_link'] as String? ??
          personal['avatar'] as String?,
      branch: value('branch_name', 'branch') ?? value('branch', 'branch'),
      organization: value('organization_name', 'organization'),
      level:
          value('level_name', 'level') ?? value('job_level_name', 'job_level'),
      position: value('position_name', 'position') ??
          value('job_position_name', 'job_position'),
    );
  }

  VisitorHost withEmployeeDetails({
    String? email,
    String? phone,
    String? avatar,
    String? branch,
    String? organization,
    String? level,
    String? position,
  }) {
    return VisitorHost(
      id: id,
      name: name,
      email: this.email ?? email,
      phone: this.phone ?? phone,
      avatar: this.avatar ?? avatar,
      branch: this.branch ?? branch,
      organization: this.organization ?? organization,
      level: this.level ?? level,
      position: this.position ?? position,
    );
  }

  final int id;
  final String name;
  final String? email, phone, avatar, branch, organization, level, position;
}

class VisitorMedia {
  const VisitorMedia({required this.url, required this.name});

  final String url;
  final String name;
}

class Visit {
  const Visit({
    required this.id,
    required this.code,
    required this.status,
    required this.date,
    required this.visitor,
    required this.host,
    required this.branch,
    required this.category,
    required this.purpose,
    required this.canCancel,
    this.arrival,
    this.departure,
    this.checkIn,
    this.checkOut,
    this.phone,
    this.email,
    this.company,
    this.notes,
    this.cancellationReason,
    this.registrationMethod,
    this.attachments = const [],
  });

  factory Visit.fromJson(Map<String, dynamic> json) {
    final visitor = json['visitor'] as Map<String, dynamic>;
    final host = json['host'] as Map<String, dynamic>;
    final attachments = <VisitorMedia>[];
    final attachmentUrls = <String>{};

    void addMedia(dynamic value) {
      if (value is List) {
        for (final item in value) {
          addMedia(item);
        }
        return;
      }

      String? url;
      String? name;
      if (value is String) {
        url = value;
      } else if (value is Map) {
        final media = Map<String, dynamic>.from(value);
        for (final key in [
          'url',
          'link',
          'file_url',
          'path',
          'file_path',
          'original_url',
          'download_url',
          'media_url',
          'image_url',
          'photo_url',
          'src',
        ]) {
          if (media[key] is String && (media[key] as String).isNotEmpty) {
            url = media[key] as String;
            break;
          }
        }
        name = media['name'] as String? ??
            media['file_name'] as String? ??
            media['filename'] as String? ??
            media['original_name'] as String?;
        if (url == null) {
          for (final key in [
            'data',
            'media',
            'file',
            'photo',
            'image',
            'attachments',
            'files',
          ]) {
            if (media.containsKey(key)) addMedia(media[key]);
          }
          return;
        }
      }

      if (url == null || url.trim().isEmpty) return;
      final normalizedUrl = url.trim();
      if (!attachmentUrls.add(normalizedUrl)) return;
      final path = Uri.tryParse(normalizedUrl)?.path;
      attachments.add(VisitorMedia(
        url: normalizedUrl,
        name: name ??
            (path == null || path.isEmpty
                ? 'Attachment'
                : Uri.decodeComponent(path.split('/').last)),
      ));
    }

    void addMediaFields(Map<String, dynamic> source) {
      for (final entry in source.entries) {
        final key = entry.key.toLowerCase();
        if (key.contains('photo') ||
            key.contains('image') ||
            key.contains('attachment') ||
            key.contains('media') ||
            key == 'file' ||
            key == 'files') {
          addMedia(entry.value);
        }
      }
    }

    addMediaFields(json);
    addMediaFields(visitor);

    String name(String key) =>
        (json[key] as Map<String, dynamic>)['name'] as String;
    return Visit(
      id: json['id'] as int,
      code: json['visit_code'] as String,
      status: json['status'] as String,
      date: json['visit_date'] as String,
      visitor: visitor['full_name'] as String,
      host: host['name'] as String,
      branch: name('branch'),
      category: name('category'),
      purpose: name('purpose'),
      canCancel: json['can_cancel'] == true,
      arrival: json['expected_arrival_at'] as String?,
      departure: json['expected_departure_at'] as String?,
      checkIn: json['check_in_at'] as String?,
      checkOut: json['check_out_at'] as String?,
      phone: visitor['phone'] as String?,
      email: visitor['email'] as String?,
      company: visitor['company'] as String?,
      notes: json['notes'] as String?,
      cancellationReason: json['cancellation_reason'] as String?,
      registrationMethod: json['registration_method'] as String?,
      attachments: attachments,
    );
  }

  final int id;
  final String code, status, date, visitor, host, branch, category, purpose;
  final bool canCancel;
  final String? arrival, departure, checkIn, checkOut, phone, email, company;
  final String? notes, cancellationReason, registrationMethod;
  final List<VisitorMedia> attachments;
}

class VisitorAttachment {
  const VisitorAttachment(this.name, this.bytes);
  final String name;
  final Uint8List bytes;
}
