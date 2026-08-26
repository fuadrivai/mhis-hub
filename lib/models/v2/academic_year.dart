class AcademicYear {
  int? id;
  String? name;
  bool? isActive;
  String? startDate;
  String? endDate;

  AcademicYear(
      {this.id, this.name, this.isActive, this.startDate, this.endDate});

  AcademicYear.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    isActive = json['is_active'];
    startDate = json['start_date'];
    endDate = json['end_date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['is_active'] = isActive;
    data['start_date'] = startDate;
    data['end_date'] = endDate;
    return data;
  }
}
