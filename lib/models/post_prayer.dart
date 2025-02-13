import 'package:jiffy/jiffy.dart';

class PostPrayer {
  int? id;
  int? userId;
  String? fullname;
  int? pinLocationsId;
  String? locationName;
  String? coordinate;
  String? note;
  String? clockTime;
  double? latitude;
  double? longitude;
  int? absentType;
  int? radius;
  double? distance;
  String? eventType;

  PostPrayer({
    this.id,
    this.userId,
    this.fullname,
    this.pinLocationsId,
    this.locationName,
    this.coordinate,
    this.note,
    this.clockTime,
    this.latitude,
    this.longitude,
    this.absentType,
    this.radius,
    this.distance,
    this.eventType,
  });

  PostPrayer.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    fullname = json['fullname'];
    pinLocationsId = json['pin_locations_id'];
    locationName = json['location_name'];
    coordinate = json['coordinate'];
    note = json['note'];
    clockTime = json['clock_time'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    absentType = json['absent_type'];
    radius = json['radius'];
    if (json['distance'].runtimeType == String) {
      distance = double.parse(json['distance']);
    } else if (json['distance'].runtimeType == int) {
      distance = json['distance'].toDouble();
    } else {
      distance = json['distance'];
    }
    eventType = json['event_type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['note'] = note;
    data['clock_time'] = clockTime;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    return data;
  }

  String date(String date) => Jiffy.parse(date, pattern: "yyyy-MM-dd hh:mm:ss")
      .format(pattern: "dd MMMM yyyy");

  String hourMinute(String date) =>
      Jiffy.parse(date, pattern: "yyyy-MM-dd hh:mm:ss")
          .format(pattern: "HH:mm");
}
