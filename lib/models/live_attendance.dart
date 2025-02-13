import 'package:dio/dio.dart';

class LiveAttendance {
  double? latitude;
  double? longitude;
  String? status;
  String? description;
  int? userId;
  MultipartFile? file;

  LiveAttendance(
      {this.latitude,
      this.longitude,
      this.status,
      this.description,
      this.userId,
      this.file});

  LiveAttendance.fromJson(Map<String, dynamic> json) {
    latitude = json['latitude'];
    longitude = json['longitude'];
    status = json['status'];
    description = json['description'];
    userId = json['user_id'];
    file = json['file'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['status'] = status;
    data['description'] = description;
    data['user_id'] = userId;
    data['file'] = file;
    return data;
  }
}
