import 'package:fl_mhis_hr/models/model.dart';
import 'package:fl_mhis_hr/service/api.dart';

class LoginApi {
  static Future<LoginResponse> onLogin(Map<String, dynamic> login) async {
    final client = await Api.restClient();
    var data = client.onLogin(login);
    return data;
  }

  static Future<dynamic> onLogout() async {
    final client = await Api.restClient();
    var data = client.onLogout();
    return data;
  }
}
