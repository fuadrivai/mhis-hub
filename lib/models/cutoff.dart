class Cutoff {
  int? id;
  String? name;
  int? cutoffDay;
  bool? isActive;

  Cutoff({this.id, this.cutoffDay, this.name, this.isActive});

  Cutoff.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    cutoffDay = json['cutoffDay'] ?? json['cutoff_day'];
    name = json['name'];
    isActive = json['isActive'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['cutoffDay'] = cutoffDay;
    data['name'] = name;
    data['isActive'] = isActive;
    return data;
  }
}
