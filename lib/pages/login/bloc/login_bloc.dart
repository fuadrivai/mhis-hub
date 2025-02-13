import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fl_mhis_hr/library/constant.dart';
import 'package:fl_mhis_hr/models/model.dart';
import 'package:fl_mhis_hr/pages/login/repository/login_api.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(const LoginState()) {
    on<OnLogin>(_onLogin);
    on<OnLogout>(_onLogout);
  }
  void _onLogin(OnLogin event, Emitter<LoginState> emit) async {
    try {
      emit(state.copyWith(
        isLoading: true,
        isError: false,
        errorMessage: "",
        showAction: false,
      ));

      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        announcement: true,
        badge: true,
        carPlay: false,
        criticalAlert: true,
        provisional: false,
        sound: true,
      );
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      String? token = await messaging.getToken();

      String device = getDeviceType();
      Map<String, dynamic> map = event.data;
      map['device_id'] = token;
      map['device'] = device;

      LoginResponse resp = await LoginApi.onLogin(map);

      await Future.wait([
        Session.set("email", resp.user?.email ?? ""),
        Session.set("name", resp.user?.name ?? ""),
        Session.set("userIdTalenta", resp.user?.userIdTalenta.toString() ?? ""),
        Session.set("token", resp.authorization?.token ?? ""),
      ]);
      emit(state.copyWith(
        isLoading: false,
        isSuccess: true,
        isError: false,
        showAction: false,
      ));
    } catch (e) {
      bool showAction = false;
      String errorMessage = e.toString();
      if (e.runtimeType == DioException) {
        DioException err = e as DioException;
        errorMessage = err.response?.data?["message"] ?? err.message;
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
