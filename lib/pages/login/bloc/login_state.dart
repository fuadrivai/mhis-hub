part of 'login_bloc.dart';

final class LoginState extends Equatable {
  final bool isLoading;
  final bool isError;
  final bool isSuccess;
  const LoginState({
    this.isLoading = true,
    this.isError = false,
    this.isSuccess = false,
  });

  LoginState copyWith({
    bool? isLoading,
    bool? isError,
    bool? isSuccess,
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      isError: isError ?? this.isError,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }

  @override
  List<Object?> get props => [isLoading, isError, isSuccess];
}
