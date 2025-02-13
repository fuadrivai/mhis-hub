import 'package:fl_mhis_hr/models/model.dart';

class DataAttendance {
  String? id;
  String? type;
  Attributes? attributes;

  DataAttendance({this.id, this.type, this.attributes});

  DataAttendance.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    type = json['type'];
    attributes = json['attributes'] != null
        ? Attributes.fromJson(json['attributes'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['type'] = type;
    if (attributes != null) {
      data['attributes'] = attributes!.toJson();
    }
    return data;
  }
}
