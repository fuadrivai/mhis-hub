class Payslip {
  int? id;
  String? email;
  String? periode;
  String? link;
  String? createdAt;
  String? updatedAt;

  Payslip({
    this.id,
    this.email,
    this.periode,
    this.link,
    this.createdAt,
    this.updatedAt,
  });

  Payslip.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    email = json['email'];
    periode = json['periode'];
    link = json['link'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['email'] = email;
    data['periode'] = periode;
    data['link'] = link;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}
