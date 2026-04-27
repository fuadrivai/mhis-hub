class ActiveSchedule {
  int? id;
  String? scheduleName;
  String? effectiveStartDate;
  String? effectiveEndDate;

  ActiveSchedule({
    this.id,
    this.scheduleName,
    this.effectiveStartDate,
    this.effectiveEndDate,
  });

  ActiveSchedule.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    scheduleName = json['schedule_name'];
    effectiveStartDate = json['effective_start_date'];
    effectiveEndDate = json['effective_end_date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['schedule_name'] = scheduleName;
    data['effective_start_date'] = effectiveStartDate;
    data['effective_end_date'] = effectiveEndDate;
    return data;
  }
}
