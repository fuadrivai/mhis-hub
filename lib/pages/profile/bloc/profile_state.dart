part of 'profile_bloc.dart';

final class ProfileState extends Equatable {
  final bool isLoading, isError;
  final AcademyUser? user;
  final String? errorMessage;
  const ProfileState({
    this.isLoading = true,
    this.isError = false,
    this.errorMessage,
    this.user,
  });

  ProfileState copyWith({
    String? errorMessage,
    bool? isLoading,
    bool? isError,
    AcademyUser? user,
  }) {
    return ProfileState(
      errorMessage: errorMessage ?? this.errorMessage,
      isLoading: isLoading ?? this.isLoading,
      isError: isError ?? this.isError,
      user: user ?? this.user,
    );
  }

  @override
  List<Object?> get props => [user, errorMessage, isLoading, isError];
}
