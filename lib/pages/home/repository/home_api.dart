import 'package:fl_mhis_hr/models/model.dart';
import 'package:fl_mhis_hr/service/api.dart';

class HomeApi {
  static Future<List<SchoolCalendar>> getSchoolCalendar() async {
    final client = await Api.restClient();
    var data = client.getSchoolCalendar();
    return data;
  }

  static Future<List<Newsletter>> getNewsletter() async {
    final client = await Api.restClient();
    var data = client.getNewsletter();
    return data;
  }
}
