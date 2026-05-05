import 'package:fl_mhis_hr/models/job_postion.dart';
import 'package:fl_mhis_hr/models/model.dart';
import 'package:fl_mhis_hr/service/api.dart';

class GeneralAnnouncementApi {
  static Future<List<AnnouncementCategory>> getCategory() async {
    final client = await Api.restClient();
    var data = client.getAllCategory();
    return data;
  }

  static Future<List<Branch>> getBranch() async {
    final client = await Api.restClient();
    var data = client.getAllBranch();
    return data;
  }

  static Future<List<Organization>> getOrganization() async {
    final client = await Api.restClient();
    var data = client.getAllOrganization();
    return data;
  }

  static Future<List<JobLevel>> getJobLevel() async {
    final client = await Api.restClient();
    var data = client.getAllJobLevel();
    return data;
  }

  static Future<List<JobPosition>> getJobPosition() async {
    final client = await Api.restClient();
    var data = client.getAllJobPosition();
    return data;
  }

  static Future<List<Announcement>> getAnnouncement(
      {Map<String, dynamic>? params}) async {
    final client = await Api.restClient(params: params);
    var data = client.getAnnouncement();
    return data;
  }

  static Future<Announcement> post(Announcement announcement) async {
    final client = await Api.restClient();
    var data = client.postAnnouncement(announcement);
    return data;
  }
}
