import 'package:dio/dio.dart';
import 'package:fl_mhis_hr/injector/injector.dart';
import 'package:fl_mhis_hr/library/constant.dart';
import 'package:fl_mhis_hr/service/restclient.dart';

class Api {
  // static const String url = "http://192.168.206.62:3000";
  static const String url = "https://mhis-hub.mhis.link";

  static const String baseUrl = "$url/api/";

  static Future<Dio> dioClient({Map<String, dynamic>? params}) async {
    final dio = Dio();
    final token = (await Session.get("token"))?.trim();

    dio.interceptors.clear();
    dio.interceptors.add(DioInterceptors(dio));
    if (token != null && token.isNotEmpty) {
      dio.options.headers["Authorization"] =
          token.toLowerCase().startsWith("bearer ") ? token : "Bearer $token";
    }
    dio.options.headers["Content-Type"] = "application/json";
    dio.options.headers["Accept"] = "application/json";
    dio.options.headers["X-Requested-With"] = "XMLHttpRequest";
    dio.options.queryParameters = params ?? {};
    return dio;
  }

  static Future<RestClient> restClient({
    Map<String, dynamic>? params,
    String? baseurl,
  }) async {
    final dio = await dioClient(params: params);
    return RestClient(dio, baseUrl: baseurl ?? baseUrl);
  }
}
