import 'package:dio/dio.dart';
import 'package:fl_mhis_hr/injector/injector.dart';
import 'package:fl_mhis_hr/library/constant.dart';
import 'package:fl_mhis_hr/service/restclient.dart';

class Api {
  static const String baseUrl = "http://192.168.207.251:3000/api/";
  // static const String baseUrl = "https://mhis-hub.mhis.link/api/";

  static Future<Dio> dioClient({Map<String, dynamic>? params}) async {
    final dio = Dio();
    final token = (await Session.get("token"))?.trim();

    dio.interceptors.clear();
    dio.interceptors.add(DioInterceptors(dio));
    if (token != null && token.isNotEmpty) {
      dio.options.headers["Authorization"] = token.toLowerCase().startsWith(
                "bearer ",
              )
          ? token
          : "Bearer $token";
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
