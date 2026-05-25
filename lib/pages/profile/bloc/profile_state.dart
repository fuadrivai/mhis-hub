part of 'profile_bloc.dart';

final class ProfileState extends Equatable {
  final bool isLoading, isError, loadingFormPassword;
  final AcademyUser? user;
  final String? errorMessage;
  final String? passwordErrorMessage;
  final Employee? employee;
  final PackageInfo? packageInfo;
  final bool? canAuthenticateWithBiometrics;
  final bool? isBiometric;
  const ProfileState({
    this.canAuthenticateWithBiometrics = false,
    this.isLoading = true,
    this.isError = false,
    this.loadingFormPassword = false,
    this.errorMessage,
    this.passwordErrorMessage,
    this.user,
    this.employee,
    this.packageInfo,
    this.isBiometric,
  });

  ProfileState copyWith({
    String? errorMessage,
    String? passwordErrorMessage,
    bool? isLoading,
    bool? isError,
    bool? loadingFormPassword,
    AcademyUser? user,
    Employee? employee,
    PackageInfo? packageInfo,
    bool? canAuthenticateWithBiometrics,
    bool? isBiometric,
  }) {
    return ProfileState(
      errorMessage: errorMessage ?? this.errorMessage,
      isLoading: isLoading ?? this.isLoading,
      isError: isError ?? this.isError,
      loadingFormPassword: loadingFormPassword ?? this.loadingFormPassword,
      passwordErrorMessage: passwordErrorMessage ?? this.passwordErrorMessage,
      user: user ?? this.user,
      employee: employee ?? this.employee,
      packageInfo: packageInfo ?? this.packageInfo,
      canAuthenticateWithBiometrics:
          canAuthenticateWithBiometrics ?? this.canAuthenticateWithBiometrics,
      isBiometric: isBiometric ?? this.isBiometric,
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
        packageInfo,
        canAuthenticateWithBiometrics,
        isBiometric,
      ];
}
