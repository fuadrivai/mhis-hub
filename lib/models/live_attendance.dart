
import 'package:dio/dio.dart';

class LiveAttendance {
  double? latitude;
  double? longitude;
  String? status;
  String? description;
  String? type;
  int? userId;
  String? date;
  String? photo;
  MultipartFile? file;

  LiveAttendance(
      {this.latitude,
      this.longitude,
      this.status,
      this.description,
      this.date,
      this.photo,
      this.type,
      this.userId,
      this.file});

  LiveAttendance.fromJson(Map<String, dynamic> json) {
    latitude = json['latitude'];
    longitude = json['longitude'];
    status = json['status'];
    description = json['description'];
    userId = json['user_id'];
    date = json['date'];
    photo = json['photo'];
    file = json['file'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['status'] = status;
    data['description'] = description;
    data['user_id'] = userId;
    data['date'] = date;
    data['photo'] = photo;
    data['file'] = file;
    data['type'] = type;
    return data;
  }
}
