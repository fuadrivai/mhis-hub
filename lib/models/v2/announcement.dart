import 'package:fl_mhis_hr/models/v2/models.dart';

class Announcement {
  int? id;
  String? title;
  String? content;
  String? link;
  String? attachment;
  String? publishAt;
  bool? allEmployees;
  bool? sendEmail;
  bool? sendPushNotification;
  String? status;
  List<Branch>? branches;
  List<JobLevel>? jobLevels;
  List<Organization>? organizations;
  List<JobPosition>? positions;
  AnnouncementCategory? category;
  Employee? creator;
  Employee? updater;

  Announcement(
      {this.id,
      this.title,
      this.content,
      this.link,
      this.attachment,
      this.publishAt,
      this.allEmployees,
      this.sendEmail,
      this.sendPushNotification,
      this.status,
      this.branches,
      this.jobLevels,
      this.organizations,
      this.positions,
      this.category,
      this.creator,
      this.updater});

  Announcement.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    content = json['content'];
    link = json['link'];
    attachment = json['attachment'];
    publishAt = json['publish_at'];
    allEmployees = json['all_employees'];
    sendEmail = json['send_email'];
    sendPushNotification = json['send_push_notification'];
    status = json['status'];
    if (json['branches'] != null) {
      branches = <Branch>[];
      json['branches'].forEach((v) {
        branches!.add(Branch.fromJson(v));
      });
    }
    if (json['job_levels'] != null) {
      jobLevels = <JobLevel>[];
      json['job_levels'].forEach((v) {
        jobLevels!.add(JobLevel.fromJson(v));
      });
    }
    if (json['organizations'] != null) {
      organizations = <Organization>[];
      json['organizations'].forEach((v) {
        organizations!.add(Organization.fromJson(v));
      });
    }
    if (json['positions'] != null) {
      positions = <JobPosition>[];
      json['positions'].forEach((v) {
        positions!.add(JobPosition.fromJson(v));
      });
    }
    category = json['category'] != null
        ? AnnouncementCategory.fromJson(json['category'])
        : null;
    creator =
        json['creator'] != null ? Employee.fromJson(json['creator']) : null;
    updater =
        json['updater'] != null ? Employee.fromJson(json['updater']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['content'] = content;
    data['link'] = link;
    data['attachment'] = attachment;
    data['publish_at'] = publishAt;
    data['all_employees'] = allEmployees;
    data['send_email'] = sendEmail;
    data['send_push_notification'] = sendPushNotification;
    data['status'] = status;
    if (branches != null) {
      data['branches'] = branches!.map((v) => v.toJson()).toList();
    }
    if (jobLevels != null) {
      data['job_levels'] = jobLevels!.map((v) => v.toJson()).toList();
    }
    if (organizations != null) {
      data['organizations'] = organizations!.map((v) => v.toJson()).toList();
    }
    if (positions != null) {
      data['positions'] = positions!.map((v) => v.toJson()).toList();
    }
    if (category != null) {
      data['category'] = category!.toJson();
    }
    if (creator != null) {
      data['creator'] = creator!.toJson();
    }
    if (updater != null) {
      data['updater'] = updater!.toJson();
    }
    return data;
  }
}
