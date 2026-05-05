import 'package:fl_mhis_hr/models/model.dart';
import 'package:fl_mhis_hr/service/api.dart';

class KpiApi {
  static Future<Kpi> get() async {
    final client = await Api.restClient();
    var data = client.getKpi();
    return data;
  }
}
