import 'package:dio/dio.dart';
import 'package:fl_mhis_hr/library/constant.dart';
import 'package:fl_mhis_hr/injector/injector.dart';
import 'package:go_router/go_router.dart';

class DioInterceptors extends InterceptorsWrapper {
  final Dio dio;
  DioInterceptors(this.dio);
  final NavigationService _nav = locator<NavigationService>();

  String _resolveErrorMessage(DioException err) {
    final data = err.response?.data;

    if (data is Map<String, dynamic>) {
      return (data['message'] ?? err.message ?? "Gagal Mengakses Server")
          .toString();
    }

    if (data is String && data.isNotEmpty) {
      if (data.contains('<!DOCTYPE html>')) {
        return "Respon server tidak valid (terdeteksi redirect HTML).";
      }
      return data;
    }

    return err.message ?? "Gagal Mengakses Server";
  }

  @override
  Future onError(DioException err, ErrorInterceptorHandler handler) async {
    int? responseCode = err.response?.statusCode;
    final errorMessage = _resolveErrorMessage(err);

    if (responseCode != null) {
      if (responseCode == 302 || responseCode == 401 || responseCode == 403) {
        Session.clear().then((value) {
          (_nav.navKey.currentContext!).go("/auth");
        });
      } else {
        Common.modalInfo(
          _nav.navKey.currentContext!,
          title: "Error",
          mode: MODE.error,
          message: errorMessage,
        );
      }
    } else {
      Common.modalInfo(
        _nav.navKey.currentContext!,
        title: "Error",
        mode: MODE.error,
        message: errorMessage,
      );
    }
    super.onError(err, handler);
  }
}
