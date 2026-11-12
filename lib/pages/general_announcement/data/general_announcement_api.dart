import 'package:fl_mhis_hr/models/v2/models.dart';
import 'package:fl_mhis_hr/injector/dio_interceptor.dart';
import 'package:fl_mhis_hr/service/api.dart';

class GeneralAnnouncementApi {
  static Future<List<AnnouncementCategory>> getCategory() async {
    final client = await Api.restClient();
    var data = client.getAllCategory();
    return data;
  }

  static Future<List<Branch>> getBranch(
      {bool handleErrorsLocally = false}) async {
    final client = await Api.restClient(
      extra: {DioInterceptors.handleErrorsLocally: handleErrorsLocally},
    );
    var data = client.getAllBranch();
    return data;
  }

  static Future<List<Organization>> getOrganization(
      {bool handleErrorsLocally = false}) async {
    final client = await Api.restClient(
      extra: {DioInterceptors.handleErrorsLocally: handleErrorsLocally},
    );
    var data = client.getAllOrganization();
    return data;
  }

  static Future<List<JobLevel>> getJobLevel(
      {bool handleErrorsLocally = false}) async {
    final client = await Api.restClient(
      extra: {DioInterceptors.handleErrorsLocally: handleErrorsLocally},
    );
    var data = client.getAllJobLevel();
    return data;
  }

  static Future<List<JobPosition>> getJobPosition(
      {bool handleErrorsLocally = false}) async {
    final client = await Api.restClient(
      extra: {DioInterceptors.handleErrorsLocally: handleErrorsLocally},
    );
    var data = client.getAllJobPosition();
    return data;
  }

  static Future<List<Announcement>> getAnnouncement(
      {Map<String, dynamic>? params,
      bool handleForbiddenLocally = false}) async {
    final client = await Api.restClient(
      params: params,
      extra: {DioInterceptors.handleForbiddenLocally: handleForbiddenLocally},
    );
    var data = client.getAnnouncement();
    return data;
  }

  static Future<Announcement> post(Announcement announcement) async {
    final client = await Api.restClient();
    var data = client.postAnnouncement(announcement);
    return data;
  }
}
