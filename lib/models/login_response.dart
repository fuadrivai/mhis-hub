class LoginResponse {
  String? status;
  User? user;
  Authorization? authorization;

  LoginResponse({this.status, this.user, this.authorization});

  LoginResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    user = json['user'] != null ? User.fromJson(json['user']) : null;
    authorization = json['authorization'] != null
        ? Authorization.fromJson(json['authorization'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    if (user != null) {
      data['user'] = user!.toJson();
    }
    if (authorization != null) {
      data['authorization'] = authorization!.toJson();
    }
    return data;
  }
}

class User {
  int? id;
  String? name;
  String? email;
  String? emailVerifiedAt;
  String? createdAt;
  String? updatedAt;
  int? userIdTalenta;

  User({
    this.id,
    this.name,
    this.email,
    this.emailVerifiedAt,
    this.createdAt,
    this.updatedAt,
    this.userIdTalenta,
  });

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    emailVerifiedAt = json['email_verified_at'];
    createdAt = json['created_at'];
    userIdTalenta = json['user_id_talenta'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['email'] = email;
    data['email_verified_at'] = emailVerifiedAt;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

class Authorization {
  String? token;
  String? type;

  Authorization({this.token, this.type});

  Authorization.fromJson(Map<String, dynamic> json) {
    token = json['token'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['token'] = token;
    data['type'] = type;
    return data;
  }
}
