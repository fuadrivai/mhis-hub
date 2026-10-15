class Sop {
  final int? id;
  final String? link;
  final String? title;
  final bool? isActive;

  const Sop({
    this.id,
    this.link,
    this.title,
    this.isActive,
  });

  factory Sop.fromJson(Map<String, dynamic> json) {
    return Sop(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}'),
      link: json['link'] as String?,
      title: json['title'] as String?,
      isActive: json['is_active'] as bool?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'link': link,
        'title': title,
        'is_active': isActive,
      };
}
