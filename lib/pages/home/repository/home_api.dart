import 'package:fl_mhis_hr/models/model.dart';
import 'package:fl_mhis_hr/service/api.dart';

class HomeApi {
  static Future<List<Schedule>> getSchoolCalendar(String url) async {
    final client = await Api.restClient(baseurl: url);
    var data = client.getSchoolCalendar();
    return data;
  }
}
