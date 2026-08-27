class User {
  int? id;
  String? name;
  String? email;
  String? emailVerifiedAt;
  int? userIdTalenta;
  String? createdAt;
  String? updatedAt;
  List<Role>? roles;

  User({
    this.id,
    this.name,
    this.email,
    this.emailVerifiedAt,
    this.userIdTalenta,
    this.createdAt,
    this.updatedAt,
    this.roles = const [],
  });

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    emailVerifiedAt = json['email_verified_at'];
    userIdTalenta = json['user_id_talenta'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    roles = (json['roles'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(Role.fromJson)
        .toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['email'] = email;
    data['email_verified_at'] = emailVerifiedAt;
    data['user_id_talenta'] = userIdTalenta;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['roles'] = (roles ?? []).map((role) => role.toJson()).toList();
    return data;
  }
}

class Role {
  final int? id;
  final String? name;
  final String? guardName;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Role({
    this.id,
    this.name,
    this.guardName,
    this.createdAt,
    this.updatedAt,
  });

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      id: _toInt(json['id']),
      name: json['name']?.toString(),
      guardName: json['guard_name']?.toString(),
      createdAt: _toDateTime(json['created_at']),
      updatedAt: _toDateTime(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'guard_name': guardName,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    return int.tryParse(value.toString());
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}
