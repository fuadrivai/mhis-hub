import 'package:fl_mhis_hr/models/model.dart';
import 'package:fl_mhis_hr/service/api.dart';

class ClockInPrayerApi {
  static Future<PostPrayer> postPrayer(PostPrayer post) async {
    final client = await Api.restClient();
    var data = client.postPrayer(post);
    return data;
  }

  static Future<List<PostPrayer>> get(Map<String, dynamic> post) async {
    final client = await Api.restClient();
    var data = client.getPrayerHistory(post);
    return data;
  }
}
