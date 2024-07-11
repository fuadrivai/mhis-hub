import 'package:fl_mhis_hr/models/model.dart';
import 'package:fl_mhis_hr/service/api.dart';

class LoginApi {
  static Future<bool> checkUser(String email) async {
    final client = await Api.restClient();
    var data = client.checkUser(email);
    return data;
  }

  static Future<AcademyUser> getUserByEmail(String email) async {
    final client = await Api.restClient();
    var data = client.getUserByEmail(email);
    return data;
  }
}
