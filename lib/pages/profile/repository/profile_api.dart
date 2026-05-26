import 'package:fl_mhis_hr/service/api.dart';

class ProfileApi {
  static Future<dynamic> changePassword(Map<String, dynamic> map) async {
    final client = await Api.restClient();
    var data = client.changePassword(map);
    return data;
  }
}
