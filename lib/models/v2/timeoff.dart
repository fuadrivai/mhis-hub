class Timeoff {
  int? id;
  String? code;
  String? name;
  List<TimeoffSchema>? schema;
  bool? isActive;

  Timeoff({
    this.id,
    this.code,
    this.name,
    this.schema,
    this.isActive,
  });

  Timeoff.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    code = json['code'];
    name = json['name'];
    schema = json['schema'] != null
        ? (json['schema'] as List)
            .map((e) => TimeoffSchema.fromJson(e))
            .toList()
        : null;
    isActive = json['is_active'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['code'] = code;
    data['name'] = name;
    if (schema != null) {
      data['schema'] = schema!.map((e) => e.toJson()).toList();
    }
    data['is_active'] = isActive;
    return data;
  }
}

class TimeoffSchema {
  String? name;
  String? type;
  String? label;
  List<dynamic>? options;
  bool? required;
  Map<String, dynamic>? showIf;

  TimeoffSchema({
    this.name,
    this.type,
    this.label,
    this.options,
    this.required,
    this.showIf,
  });

  TimeoffSchema.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    type = json['type'];
    label = json['label'];
    options =
        json['options'] != null ? List<dynamic>.from(json['options']) : null;
    required = json['required'];
    showIf = json['show_if'] != null
        ? Map<String, dynamic>.from(json['show_if'] as Map)
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['type'] = type;
    data['label'] = label;
    data['options'] = options;
    data['required'] = required;
    if (showIf != null) data['show_if'] = showIf;
    return data;
  }
}
