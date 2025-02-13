import 'package:dio/dio.dart';
import 'package:fl_mhis_hr/library/constant.dart';
import 'package:fl_mhis_hr/injector/injector.dart';
import 'package:go_router/go_router.dart';

class DioInterceptors extends InterceptorsWrapper {
  final Dio dio;
  DioInterceptors(this.dio);
  final NavigationService _nav = locator<NavigationService>();

  @override
  Future onError(err, handler) async {
    int? responseCode = err.response?.statusCode;
    var data = err.response?.data;
    // ignore: avoid_print
    print(data);
    if (responseCode != null) {
      if (responseCode == 403) {
        Session.clear().then((value) {
          (_nav.navKey.currentContext!).go("/auth");
        });
      } else {
        Common.modalInfo(
          _nav.navKey.currentContext!,
          title: "Error",
          mode: MODE.error,
          message: err.response?.data['message'] ??
              err.message ??
              "Gagal Mengakses Server",
        );
      }
    } else {
      Common.modalInfo(
        _nav.navKey.currentContext!,
        title: "Error",
        mode: MODE.error,
        message: err.response?.data['message'] ??
            err.message ??
            "Gagal Mengakses Server",
      );
    }
    super.onError(err, handler);
  }
}
