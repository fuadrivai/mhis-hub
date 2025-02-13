import 'package:fl_mhis_hr/models/job_postion.dart';
import 'package:fl_mhis_hr/models/model.dart';

class Announcement {
  int? id;
  String? subject;
  String? content;
  String? link;
  AnnouncementCategory? category;
  User? user;
  String? date;
  bool? allEmployees;
  List<Branch>? branches;
  List<JobLevel>? levels;
  List<Organization>? organizations;
  List<JobPosition>? positions;

  Announcement({
    this.id,
    this.subject,
    this.content,
    this.link,
    this.category,
    this.date,
    this.allEmployees = true,
    this.branches,
    this.levels,
    this.organizations,
    this.positions,
  });

  Announcement.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    subject = json['subject'];
    link = json['link'];
    content = json['content'];
    category = json['category'] != null
        ? AnnouncementCategory.fromJson(json['category'])
        : null;
    user = json['user'] != null ? User.fromJson(json['user']) : null;
    date = json['date'];
    allEmployees = json['all_employees'];
    if (json['branches'] != null) {
      branches = <Branch>[];
      json['branches'].forEach((v) {
        branches!.add(Branch.fromJson(v));
      });
    }
    if (json['levels'] != null) {
      levels = <JobLevel>[];
      json['levels'].forEach((v) {
        levels!.add(JobLevel.fromJson(v));
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
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['subject'] = subject;
    data['content'] = content;
    data['link'] = link;
    if (category != null) {
      data['category'] = category!.toJson();
    }
    data['date'] = date;
    data['all_employees'] = allEmployees;
    if (branches != null) {
      List<int> listBranch = [];
      for (Branch e in branches!) {
        listBranch.add(e.id!);
      }
      data['branches'] = listBranch;
    } else {
      data['branches'] = [];
    }
    if (levels != null) {
      List<int> listLevel = [];
      for (JobLevel e in levels!) {
        listLevel.add(e.id!);
      }
      data['levels'] = listLevel;
    } else {
      data['levels'] = [];
    }
    if (organizations != null) {
      List<int> listOrganization = [];
      for (Organization e in organizations!) {
        listOrganization.add(e.id!);
      }
      data['organizations'] = listOrganization;
    } else {
      data['organizations'] = [];
    }
    if (positions != null) {
      List<int> listposition = [];
      for (JobPosition e in positions!) {
        listposition.add(e.id!);
      }
      data['positions'] = listposition;
    } else {
      data['positions'] = [];
    }
    return data;
  }
}
