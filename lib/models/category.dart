class Category {
  int? id;
  String? slug;
  int? parentId;
  String? icon;
  int? order;
  String? title;

  Category({
    this.id,
    this.slug,
    this.parentId,
    this.icon,
    this.order,
    this.title,
  });

  Category.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    slug = json['slug'];
    parentId = json['parent_id'];
    icon = json['icon'];
    order = json['order'];
    title = json['title'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['slug'] = slug;
    data['parent_id'] = parentId;
    data['icon'] = icon;
    data['order'] = order;
    data['title'] = title;
    return data;
  }
}
