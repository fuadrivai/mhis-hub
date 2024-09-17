class SchoolCalendar {
  String? subject;
  String? starttime;
  String? endtime;
  String? color;

  SchoolCalendar({this.subject, this.starttime, this.endtime, this.color});

  SchoolCalendar.fromJson(Map<String, dynamic> json) {
    subject = json['subject'];
    starttime = json['starttime'];
    endtime = json['endtime'];
    color = json['color'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['subject'] = subject;
    data['starttime'] = starttime;
    data['endtime'] = endtime;
    data['color'] = color;
    return data;
  }
}
