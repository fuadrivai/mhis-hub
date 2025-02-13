class AccessRole {
  int? id;
  String? name;
  int? roleId;
  String? roleName;
  String? roleType;

  AccessRole({this.id, this.name, this.roleId, this.roleName, this.roleType});

  AccessRole.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    roleId = json['role_id'];
    roleName = json['role_name'];
    roleType = json['role_type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['role_id'] = roleId;
    data['role_name'] = roleName;
    data['role_type'] = roleType;
    return data;
  }
}
