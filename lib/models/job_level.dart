class JobLebel {
  int? id;
  String? title;
  int? level;

  JobLebel({this.id, this.title, this.level});

  JobLebel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    level = json['level'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['level'] = level;
    return data;
  }
}
