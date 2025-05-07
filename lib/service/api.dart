import 'package:dio/dio.dart';
import 'package:fl_mhis_hr/injector/injector.dart';
import 'package:fl_mhis_hr/library/constant.dart';
import 'package:fl_mhis_hr/service/restclient.dart';

class Api {
  // static const String baseUrl = "http://192.168.207.15:3000/api/";
  // static const String baseUrl = "http://192.168.1.8:3000/api/";
  static const String baseUrl = "https://mhis-hub.mhis.link/api/";

  static restClient({Map<String, dynamic>? params, String? baseurl}) async {
    final dio = Dio();
    dio.interceptors.clear();
    dio.interceptors.add(DioInterceptors(dio));
    dio.options.headers["Authorization"] = await Session.get("token");
    dio.options.headers["Content-Type"] = "application/json";
    dio.options.headers["Accept"] = "*/*";
    dio.options.queryParameters = params ?? {};
    return RestClient(dio, baseUrl: baseurl ?? baseUrl);
  }
}
