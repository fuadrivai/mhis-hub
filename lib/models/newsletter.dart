class Newsletter {
  String? level;
  String? newsletter;
  String? link;

  Newsletter({this.level, this.newsletter, this.link});

  Newsletter.fromJson(Map<String, dynamic> json) {
    level = json['level'];
    newsletter = json['newsletter'];
    link = json['link'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['level'] = level;
    data['newsletter'] = newsletter;
    data['link'] = link;
    return data;
  }
}
