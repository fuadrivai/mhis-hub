part of 'login_bloc.dart';

abstract class LoginEvent extends Equatable {
  const LoginEvent();
}

class OnLoginGoole extends LoginEvent {
  const OnLoginGoole();
  @override
  List<Object?> get props => [];
}
