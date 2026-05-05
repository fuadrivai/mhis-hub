import 'package:equatable/equatable.dart';
import 'package:fl_mhis_hr/injector/injector.dart';
import 'package:fl_mhis_hr/library/constant.dart';
import 'package:fl_mhis_hr/models/model.dart';
import 'package:fl_mhis_hr/pages/login/repository/login_api.dart';
import 'package:fl_mhis_hr/pages/profile/repository/profile_api.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';
import 'package:package_info_plus/package_info_plus.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final NavigationService _nav = locator<NavigationService>();
  final LocalAuthentication auth = LocalAuthentication();

  ProfileBloc() : super(const ProfileState()) {
    on<OnLogout>(_onLogout);
    on<OnGetUserById>(_onGetUserById);
    on<OnChangePassword>(_onChangePassword);
    on<OnResetAuthenticationBiometrics>(_onResetAuthenticationBiometrics);
  }

  void _onLogout(OnLogout event, Emitter<ProfileState> emit) async {
    await LoginApi.onLogout();
    await Session.clear();
    _nav.navKey.currentContext!.go("/auth");
  }

  void _onChangePassword(
      OnChangePassword event, Emitter<ProfileState> emit) async {
    try {
      emit(state.copyWith(loadingFormPassword: true));
      Map<String, dynamic> data = event.data;
      await ProfileApi.changePassword(data);
      emit(state.copyWith(loadingFormPassword: false));
    } catch (e) {
      emit(state.copyWith(
        loadingFormPassword: false,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onResetAuthenticationBiometrics(
      OnResetAuthenticationBiometrics event, Emitter<ProfileState> emit) async {
    try {
      emit(state.copyWith(loadingFormPassword: true));
      bool isBiometric = event.isBiometric;
      await Session.set("isBiometric", isBiometric.toString());
      emit(state.copyWith(isBiometric: isBiometric));
    } catch (e) {
      emit(state.copyWith(
        isBiometric: state.isBiometric,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onGetUserById(OnGetUserById event, Emitter<ProfileState> emit) async {
    try {
      emit(state.copyWith(isLoading: true));

      Employee employee = await ProfileApi.getEmployeeById(event.id);
      final packageInfo = await PackageInfo.fromPlatform();
      bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
      bool? isBiometric =
          await Session.get("isBiometric") == "true" ? true : false;

      emit(state.copyWith(
        employee: employee,
        isLoading: false,
        isError: false,
        packageInfo: packageInfo,
        canAuthenticateWithBiometrics: canAuthenticateWithBiometrics,
        isBiometric: isBiometric,
      ));
    } catch (e) {
      emit(state.copyWith(
        employee: state.employee,
        isLoading: false,
        isError: false,
        packageInfo: state.packageInfo,
        canAuthenticateWithBiometrics: state.canAuthenticateWithBiometrics,
        isBiometric: state.isBiometric,
      ));
    }
  }
}
