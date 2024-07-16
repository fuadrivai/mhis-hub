part of 'academy_bloc.dart';

final class AcademyState extends Equatable {
  final String? email;
  final bool isLoading;
  final bool isError;
  final String? errorMessage;
  const AcademyState({
    this.email,
    this.isLoading = true,
    this.isError = false,
    this.errorMessage,
  });

  AcademyState copyWith({
    String? email,
    bool? isLoading,
    bool? isError,
    String? errorMessage,
  }) {
    return AcademyState(
      email: email ?? this.email,
      errorMessage: errorMessage ?? this.errorMessage,
      isLoading: isLoading ?? this.isLoading,
      isError: isError ?? this.isError,
    );
  }

  @override
  List<Object?> get props => [email, errorMessage, isLoading, isError];
}
