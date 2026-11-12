// ignore_for_file: deprecated_member_use

import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fl_mhis_hr/library/constant.dart';
import 'package:fl_mhis_hr/models/v2/models.dart';
import 'package:fl_mhis_hr/pages/login/repository/login_api.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:jwt_decoder/jwt_decoder.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc({
    Future<LoginResponse> Function(Map<String, dynamic>)? login,
    Future<String?> Function()? getMessagingToken,
  })  : _login = login ?? LoginApi.onLogin,
        _getMessagingToken = getMessagingToken ?? _requestMessagingToken,
        super(const LoginState()) {
    on<OnLogin>(_onLogin);
    on<OnLogout>(_onLogout);
  }
  final Future<LoginResponse> Function(Map<String, dynamic>) _login;
  final Future<String?> Function() _getMessagingToken;

  static Future<String?> _requestMessagingToken() async {
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: false,
      criticalAlert: true,
      provisional: false,
      sound: true,
    );
    return FirebaseMessaging.instance.getToken();
  }

  void _onLogin(OnLogin event, Emitter<LoginState> emit) async {
    try {
      emit(state.copyWith(
        isLoading: true,
        isSuccess: false,
        isError: false,
        isInactive: false,
        errorMessage: "",
        showAction: false,
      ));

      String? token = await _getMessagingToken();

      String device = getDeviceType();
      Map<String, dynamic> map = event.data;
      map['device_id'] = token;
      map['device'] = device;

      String password = map["password"];

      LoginResponse resp = await _login(map);
      Map<String, dynamic> decodedToken =
          JwtDecoder.decode(resp.authorization?.token ?? "");
      await Future.wait([
        Session.set("email", resp.user?.email ?? ""),
        Session.set("name", resp.user?.name ?? ""),
        Session.set("password", password),
        Session.set("userIdTalenta", resp.user?.userIdTalenta.toString() ?? ""),
        Session.set("token", resp.authorization?.token ?? ""),
        Session.set("userId", decodedToken["id"].toString()),
        Session.set("employeeId", decodedToken["employee_id"].toString()),
        Session.set(
            "roles",
            (resp.user?.roles?.map((role) => role.name).toList() ?? [])
                .toString()),
      ]);
      emit(state.copyWith(
        isLoading: false,
        isSuccess: true,
        isError: false,
        showAction: false,
      ));
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 403) {
        emit(state.copyWith(
          isLoading: false,
          isSuccess: false,
          isError: false,
          isInactive: true,
        ));
        return;
      }
      bool showAction = false;
      String errorMessage = e.toString();
      if (e is DioException) {
        final data = e.response?.data;
        final message = data is Map ? data['message'] : null;
        errorMessage =
            message is String ? message : (e.message ?? e.toString());
      }
      emit(state.copyWith(
        isLoading: false,
        isSuccess: false,
        showAction: showAction,
        isError: true,
        errorMessage: errorMessage,
      ));
    }
  }

  void _onLogout(OnLogout event, Emitter<LoginState> emit) async {
    emit(state.copyWith(isLoading: true));
    await LoginApi.onLogout();
    await Session.clear();
    emit(state.copyWith(isLoading: false, isSuccess: true, isError: false));
  }

  String getDeviceType() {
    if (kIsWeb) {
      return 'Web';
    } else if (Platform.isAndroid) {
      return 'Android';
    } else if (Platform.isIOS) {
      return 'iOS';
    } else {
      return 'Other';
    }
  }
}
