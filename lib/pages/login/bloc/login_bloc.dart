import 'package:equatable/equatable.dart';
import 'package:fl_mhis_hr/library/constant.dart';
import 'package:fl_mhis_hr/models/model.dart';
import 'package:fl_mhis_hr/pages/login/repository/login_api.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(const LoginState()) {
    on<OnLoginGoole>(_onLoginGoogle);
    on<OnLogin>(_onLogin);
    on<OnLogout>(_onLogout);
  }

  void _onLoginGoogle(OnLoginGoole event, Emitter<LoginState> emit) async {}

  void _onLogin(OnLogin event, Emitter<LoginState> emit) async {
    emit(state.copyWith(isLoading: true));
    bool isExist = await LoginApi.checkUser(event.data['email']);
    if (isExist) {
      LoginResponse resp = await LoginApi.onLogin(event.data);
      await Future.wait([
        Session.set("email", resp.user?.email ?? ""),
        Session.set("name", resp.user?.name ?? ""),
        Session.set("token",
            "${resp.authorisation?.type} ${resp.authorisation?.token ?? ""}"),
      ]);
      emit(state.copyWith(isLoading: false, isSuccess: true, isError: false));
    } else {
      emit(state.copyWith(
        isLoading: false,
        isSuccess: false,
        isError: true,
        errorMessage: "Cannot find email in Academy system",
      ));
    }
  }

  void _onLogout(OnLogout event, Emitter<LoginState> emit) async {
    emit(state.copyWith(isLoading: true));
    await LoginApi.onLogout();
    await Session.clear();
    emit(state.copyWith(isLoading: false, isSuccess: true, isError: false));
  }
}
