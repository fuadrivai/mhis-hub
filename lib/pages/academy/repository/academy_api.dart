import 'package:fl_mhis_hr/service/api.dart';

class AcademyApi {
  static Future<dynamic> academyLogin(String email) async {
    final client = await Api.restClient(
        baseurl: "http://academy.mhis.link/login-url?username=$email");
    var data = client.academyLogin();
    return data;
  }
}
