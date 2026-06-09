part of 'profile_bloc.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();
}

class OnLogout extends ProfileEvent {
  const OnLogout();
  @override
  List<Object> get props => [];
}

class OnResetAuthenticationBiometrics extends ProfileEvent {
  final bool isBiometric;
  const OnResetAuthenticationBiometrics(this.isBiometric);
  @override
  List<Object> get props => [];
}

class OnGetUserById extends ProfileEvent {
  const OnGetUserById();
  @override
  List<Object> get props => [];
}

class OnChangePassword extends ProfileEvent {
  final Map<String, dynamic> data;
  const OnChangePassword(this.data);
  @override
  List<Object> get props => [];
}

class OnRegisterFace extends ProfileEvent {
  final Map<String, dynamic> data;
  const OnRegisterFace(this.data);
  @override
  List<Object> get props => [];
}
