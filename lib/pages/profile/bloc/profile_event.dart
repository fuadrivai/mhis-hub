part of 'profile_bloc.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();
}

class OnLogout extends ProfileEvent {
  const OnLogout();
  @override
  List<Object> get props => [];
}

class OnGetUserById extends ProfileEvent {
  final int id;
  const OnGetUserById(this.id);
  @override
  List<Object> get props => [];
}

class OnChangePassword extends ProfileEvent {
  final Map<String, dynamic> data;
  const OnChangePassword(this.data);
  @override
  List<Object> get props => [];
}
