import 'package:fl_mhis_hr/models/model.dart';
import 'package:fl_mhis_hr/models/v2/employee.dart';
import 'package:fl_mhis_hr/service/api.dart';

class EmployeeApi {
  static Future<ServerSideEmployee> getEmployee(
      {Map<String, dynamic>? params}) async {
    final client = await Api.restClient(params: params);
    var data = client.getEmployee();
    return data;
  }

  static Future<Employee> getEmployeeProfile() async {
    final client = await Api.restClient();
    var data = client.getEmployeeProfile();
    return data;
  }

  static Future<Pagination> getEmployees({Map<String, dynamic>? params}) async {
    final client = await Api.restClient(params: params);
    var data = client.getEmployees();
    return data;
  }
}
