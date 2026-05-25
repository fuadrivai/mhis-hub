class Shift {
  int? id;
  String? name;
  String? code;
  String? shiftLabel;
  bool? holiday;
  String? scheduleIn;
  String? scheduleOut;
  String? breakStart;
  String? breakEnd;
  bool? isOvernight;
  bool? showInRequest;

  Shift({
    this.id,
    this.name,
    this.code,
    this.shiftLabel,
    this.holiday,
    this.scheduleIn,
    this.scheduleOut,
    this.breakStart,
    this.breakEnd,
    this.isOvernight,
    this.showInRequest,
  });

  Shift.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    code = json['code'];
    shiftLabel = json['shift_label'];
    holiday = json['holiday'];
    scheduleIn = json['schedule_in'];
    scheduleOut = json['schedule_out'];
    breakStart = json['break_start'];
    breakEnd = json['break_end'];
    isOvernight = json['is_overnight'];
    showInRequest = json['show_in_request'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['code'] = code;
    data['shift_label'] = shiftLabel;
    data['holiday'] = holiday;
    data['schedule_in'] = scheduleIn;
    data['schedule_out'] = scheduleOut;
    data['break_start'] = breakStart;
    data['break_end'] = breakEnd;
    data['is_overnight'] = isOvernight;
    data['show_in_request'] = showInRequest;
    return data;
  }
}
