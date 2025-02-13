part of 'login_bloc.dart';

abstract class LoginEvent extends Equatable {
  const LoginEvent();
}

class OnLoginGoole extends LoginEvent {
  const OnLoginGoole();
  @override
  List<Object?> get props => [];
}

class OnLogin extends LoginEvent {
  final Map<String, dynamic> data;
  const OnLogin(this.data);
  @override
  List<Object?> get props => [];
}

class OnLogout extends LoginEvent {
  const OnLogout();
  @override
  List<Object> get props => [];
}
