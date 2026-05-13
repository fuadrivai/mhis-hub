import 'package:fl_mhis_hr/models/v2/models.dart';
import 'package:fl_mhis_hr/service/api.dart';

class TimeoffApi {
  static Future<List<Timeoff>> get() async {
    final client = await Api.restClient();
    var data = client.getTimeoffs();
    return data;
  }

  static Future<Employee> getEmployeeById(int id) async {
    final client = await Api.restClient();
    var data = client.employeeById(id);
    return data;
  }
}
