import 'package:fl_mhis_hr/models/v2/models.dart';
import 'package:fl_mhis_hr/service/api.dart';

class RequestApprovalApi {
  static Future<List<ApprovalRequest>> getUserTimeoff(
      Map<String, dynamic> params) async {
    final client = await Api.restClient();
    var data = client.getUserTimeoff(params);
    return data;
  }

  static Future<List<Approval>> getUserApproval(
      Map<String, dynamic> params) async {
    final client = await Api.restClient();
    var data = client.getUserApproval(params);
    return data;
  }

  static Future<ApprovalRequest> getTimeoffDetail(int id) async {
    final client = await Api.restClient();
    var data = client.getTimeoffDetail(id);
    return data;
  }

  static Future<Approval> postAction(Map<String, dynamic> params) async {
    final client = await Api.restClient();
    var data = client.postAction(params);
    return data;
  }

  static Future<ApprovalRequest> postCancelRequest(
      int id, Map<String, dynamic> params) async {
    final client = await Api.restClient();
    var data = client.postCancelRequest(id, params);
    return data;
  }
}
