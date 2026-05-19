import 'package:fl_mhis_hr/models/v2/models.dart';

class ApprovalRule {
  final int id;
  final String? name;
  final String? createdAt;
  final String? updatedAt;

  final Branch? branch;
  final Organization? organization;
  final JobLevel? level;
  final JobPosition? position;

  final List<ApprovalStep> steps;

  ApprovalRule({
    required this.id,
    this.name,
    this.createdAt,
    this.updatedAt,
    this.branch,
    this.organization,
    this.level,
    this.position,
    this.steps = const [],
  });

  factory ApprovalRule.fromJson(Map<String, dynamic> json) {
    return ApprovalRule(
      id: json['id'],
      name: json['name'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      branch: json['branch'] != null ? Branch.fromJson(json['branch']) : null,
      organization: json['organization'] != null
          ? Organization.fromJson(json['organization'])
          : null,
      level: json['level'] != null ? JobLevel.fromJson(json['level']) : null,
      position: json['position'] != null
          ? JobPosition.fromJson(json['position'])
          : null,
      steps: (json['steps'] as List<dynamic>)
          .map((e) => ApprovalStep.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'created_at': createdAt,
        'updated_at': updatedAt,
        'branch': branch?.toJson(),
        'organization': organization?.toJson(),
        'level': level?.toJson(),
        'position': position?.toJson(),
        'steps': steps.map((e) => e.toJson()).toList(),
      };
}
