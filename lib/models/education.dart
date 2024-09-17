class Education {
  List<dynamic>? formalEducationHistory;
  List<dynamic>? informalEducationHistory;

  Education({this.formalEducationHistory, this.informalEducationHistory});

  Education.fromJson(Map<String, dynamic> json) {
    if (json['formal_education_history'] != null) {
      formalEducationHistory = <Null>[];
      json['formal_education_history'].forEach((v) {
        // formalEducationHistory!.add(new Null.fromJson(v));
      });
    }
    if (json['informal_education_history'] != null) {
      informalEducationHistory = <Null>[];
      json['informal_education_history'].forEach((v) {
        // informalEducationHistory!.add(new Null.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (formalEducationHistory != null) {
      data['formal_education_history'] =
          formalEducationHistory!.map((v) => v.toJson()).toList();
    }
    if (informalEducationHistory != null) {
      data['informal_education_history'] =
          informalEducationHistory!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
