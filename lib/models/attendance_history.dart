class AttendanceHistory {
  int? id;
  String? type;
  String? time;
  String? clockDatetime;
  bool? hasLocation;
  bool? showDetail;
  bool? dayoff;
  String? date;
  String? shift;
  String? scheduleIn;
  String? scheduleOut;
  String? checkin;
  String? checkout;
  String? overtime;
  String? attendanceCode;
  String? timeoffCode;
  String? timeoffName;
  bool? overnight;
  int? branch;
  String? barcode;
  String? source;

  AttendanceHistory({
    this.id,
    this.type,
    this.time,
    this.clockDatetime,
    this.hasLocation,
    this.showDetail,
    this.dayoff,
    this.date,
    this.shift,
    this.scheduleIn,
    this.scheduleOut,
    this.checkin,
    this.checkout,
    this.overtime,
    this.attendanceCode,
    this.timeoffCode,
    this.timeoffName,
    this.overnight,
    this.branch,
    this.barcode,
    this.source,
  });

  AttendanceHistory.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    type = json['type'];
    time = json['time'];
    clockDatetime = json['clock_datetime'];
    hasLocation = json['has_location'];
    showDetail = json['show_detail'];
    date = json['date'];
    shift = (json['shift'] ?? "").contains("WS") ? "Work Shift" : json['shift'];
    scheduleIn = json['schedule_in'];
    scheduleOut = json['schedule_out'];
    checkin = (json['checkin'] == "" || json['checkin'] == null)
        ? "--"
        : json['checkin'];
    checkout = (json['checkout'] == "" || json['checkout'] == null)
        ? "--"
        : json['checkout'];
    overtime = json['overtime'];
    attendanceCode = json['attendance_code'];
    timeoffCode = json['timeoff_code'];
    timeoffName = json['timeoff_name'];
    overnight = json['overnight'];
    branch = json['branch'];
    barcode = json['barcode'];
    source = json['source'];
    dayoff = json['dayoff'];
  }

  bool dayOff(String str) {
    str.toLowerCase();
    bool dayoff = false;
    if (str.contains('dayoff') || str.contains('Holiday')) {
      dayoff = true;
    }
    return dayoff;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['type'] = type;
    data['time'] = time;
    data['clock_datetime'] = clockDatetime;
    data['has_location'] = hasLocation;
    data['show_detail'] = showDetail;
    data['date'] = date;
    data['shift'] = shift;
    data['schedule_in'] = scheduleIn;
    data['schedule_out'] = scheduleOut;
    data['checkin'] = checkin;
    data['checkout'] = checkout;
    data['overtime'] = overtime;
    data['attendance_code'] = attendanceCode;
    data['timeoff_code'] = timeoffCode;
    data['timeoff_name'] = timeoffName;
    data['overnight'] = overnight;
    data['branch'] = branch;
    data['barcode'] = barcode;
    data['source'] = source;
    return data;
  }
}
