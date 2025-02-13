part of 'login_bloc.dart';

final class LoginState extends Equatable {
  final bool isLoading;
  final bool isError;
  final bool isSuccess;
  final bool showAction;
  final String? errorMessage;
  const LoginState({
    this.isLoading = false,
    this.isError = false,
    this.isSuccess = false,
    this.showAction = false,
    this.errorMessage,
  });

  LoginState copyWith({
    bool? isLoading,
    bool? isError,
    bool? isSuccess,
    bool? showAction,
    LoginResponse? resp,
    String? errorMessage,
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      isError: isError ?? this.isError,
      isSuccess: isSuccess ?? this.isSuccess,
      showAction: showAction ?? this.showAction,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        isError,
        isSuccess,
        errorMessage,
        showAction,
      ];
}
