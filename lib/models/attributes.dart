class Attributes {
  int? id;
  int? organisationUserId;
  String? eventType;
  String? scheduleDate;
  String? notes;
  String? approvalStatus;
  String? source;
  String? createdAt;
  String? updatedAt;
  String? clockTime;
  String? clockDate;
  String? locationName;
  String? latitude;
  String? longitude;
  String? coordinate;

  Attributes({
    this.id,
    this.organisationUserId,
    this.eventType,
    this.scheduleDate,
    this.notes,
    this.approvalStatus,
    this.source,
    this.createdAt,
    this.updatedAt,
    this.clockTime,
    this.clockDate,
    this.locationName,
    this.latitude,
    this.longitude,
    this.coordinate,
  });

  Attributes.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    organisationUserId = json['organisation_user_id'];
    eventType = json['event_type'];
    scheduleDate = json['schedule_date'];
    notes = json['notes'];
    approvalStatus = json['approval_status'];
    source = json['source'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    clockTime = json['clock_time'];
    clockDate = json['clock_date'];
    locationName = json['location_name'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    coordinate = json['coordinate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['organisation_user_id'] = organisationUserId;
    data['event_type'] = eventType;
    data['schedule_date'] = scheduleDate;
    data['notes'] = notes;
    data['approval_status'] = approvalStatus;
    data['source'] = source;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['clock_time'] = clockTime;
    data['clock_date'] = clockDate;
    data['location_name'] = locationName;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['coordinate'] = coordinate;
    return data;
  }
}
