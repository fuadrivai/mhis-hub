class Branch {
  int? id;
  String? name;
  String? code;
  bool? isActive;
  String? description;
  String? createdAt;
  String? updatedAt;

  Branch({
    this.id,
    this.name,
    this.code,
    this.isActive,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  Branch.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    code = json['code'];
    isActive = json['is_active'];
    description = json['description'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['code'] = code;
    data['is_active'] = isActive;
    data['description'] = description;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}
