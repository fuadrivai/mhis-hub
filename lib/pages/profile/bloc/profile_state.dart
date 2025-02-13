part of 'profile_bloc.dart';

final class ProfileState extends Equatable {
  final bool isLoading, isError, loadingFormPassword;
  final AcademyUser? user;
  final String? errorMessage;
  final String? passwordErrorMessage;
  final Employee? employee;
  const ProfileState({
    this.isLoading = true,
    this.isError = false,
    this.loadingFormPassword = false,
    this.errorMessage,
    this.passwordErrorMessage,
    this.user,
    this.employee,
  });

  ProfileState copyWith({
    String? errorMessage,
    String? passwordErrorMessage,
    bool? isLoading,
    bool? isError,
    bool? loadingFormPassword,
    AcademyUser? user,
    Employee? employee,
  }) {
    return ProfileState(
      errorMessage: errorMessage ?? this.errorMessage,
      isLoading: isLoading ?? this.isLoading,
      isError: isError ?? this.isError,
      loadingFormPassword: loadingFormPassword ?? this.loadingFormPassword,
      passwordErrorMessage: passwordErrorMessage ?? this.passwordErrorMessage,
      user: user ?? this.user,
      employee: employee ?? this.employee,
    );
  }

  @override
  List<Object?> get props => [
        user,
        errorMessage,
        isLoading,
        isError,
        loadingFormPassword,
        passwordErrorMessage,
        employee,
      ];
}
