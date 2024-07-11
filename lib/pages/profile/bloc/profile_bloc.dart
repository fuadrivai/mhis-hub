import 'package:equatable/equatable.dart';
import 'package:fl_mhis_hr/injector/injector.dart';
import 'package:fl_mhis_hr/library/constant.dart';
import 'package:fl_mhis_hr/models/model.dart';
import 'package:fl_mhis_hr/pages/login/repository/login_api.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final NavigationService _nav = locator<NavigationService>();
  ProfileBloc() : super(const ProfileState()) {
    on<OnLogout>(_onLogout);
    on<OnGetUserEmail>(_onGetUserEmail);
  }

  void _onLogout(OnLogout event, Emitter<ProfileState> emit) async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      googleSignIn.disconnect();
      await Session.clear();
      _nav.navKey.currentContext!.go("/auth");
    } catch (e) {
      print(e);
    }
  }

  void _onGetUserEmail(OnGetUserEmail event, Emitter<ProfileState> emit) async {
    try {
      emit(state.copyWith(isLoading: true));
      AcademyUser user = await LoginApi.getUserByEmail(event.email);
      emit(state.copyWith(
        user: user,
        isLoading: false,
        isError: false,
      ));
    } catch (e) {
      print(e);
    }
  }
}
