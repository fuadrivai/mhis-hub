part of 'profile_bloc.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();
}

class OnLogout extends ProfileEvent {
  const OnLogout();
  @override
  List<Object> get props => [];
}

class OnGetUserEmail extends ProfileEvent {
  final String email;
  const OnGetUserEmail(this.email);
  @override
  List<Object> get props => [];
}
