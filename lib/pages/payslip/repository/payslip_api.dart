import 'package:fl_mhis_hr/models/model.dart';
import 'package:fl_mhis_hr/service/api.dart';

class PayslipApi {
  static Future<Pagination> getPaySlipData(
      {Map<String, dynamic>? params}) async {
    final client = await Api.restClient(params: params);
    var data = client.getPaySlipData();
    return data;
  }
}
