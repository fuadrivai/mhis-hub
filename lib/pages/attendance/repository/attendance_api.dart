import 'package:dio/dio.dart';
import 'package:fl_mhis_hr/library/constant.dart';
import 'package:fl_mhis_hr/models/model.dart';
import 'package:fl_mhis_hr/models/v2/models.dart';
import 'package:fl_mhis_hr/service/api.dart';

class AttendanceApi {
  static Future<AttendanceResponse> postLiveAttendance(FormData live) async {
    final String dateString = Common.dateToUTC();
    const String requestLine = 'POST /v2/talenta/v2/live-attendance HTTP/1.1';
    final signature = Common.generateHmacSignature(
        requestLine, dateString, Common.hmacSecret);
    final String authorization =
        'hmac username="${Common.hmacUsername}", algorithm="hmac-sha256", headers="date request-line", signature="$signature"';
    final dio = Dio();
    dio.options.headers = {
      'Authorization': authorization,
      'Date': dateString,
      'Content-Type': 'multipart/form-data',
    };

    final response = await dio.post(
      'https://api.mekari.com/v2/talenta/v2/live-attendance',
      data: live,
    );
    return AttendanceResponse.fromJson(response.data);
  }

  static Future<AttendanceLog> postAttendance(
      LiveAttendance liveAttendance) async {
    final client = await Api.restClient();
    var data = client.postLiveAttendance(liveAttendance);
    return data;
  }

  static Future<List<Attendance>> getAttendaceHistories(
      Map<String, dynamic> map) async {
    final client = await Api.restClient();
    var data = client.getAttendaceHistories(map);
    return data;
  }

  static Future<Shift> getActiveShift() async {
    final client = await Api.restClient();
    var data = client.getActiveShift();
    return data;
  }

  static Future<List<AttendanceLog>> getCurrentAttendance() async {
    final client = await Api.restClient();
    var data = client.getCurrentAttendance();
    return data;
  }

  static Future<Pagination> getAll({Map<String, dynamic>? params}) async {
    final client = await Api.restClient(params: params);
    var data = client.all();
    return data;
  }

  static Future<Cutoff> getCutoff() async {
    final client = await Api.restClient();
    var data = client.getCutoff();
    return data;
  }

  static Future<AttendanceSummary> getAttendanceSummary(
      Map<String, dynamic> params) async {
    final client = await Api.restClient();
    var data = client.getAttendanceSummary(params);
    return data;
  }
}
