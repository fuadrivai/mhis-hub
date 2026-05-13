part of 'timeoff_bloc.dart';

final class TimeoffState extends Equatable {
  final bool isLoading, isError, isSuccess, loadMore;
  final bool isFormLoading, isFormError, isFormSuccess;
  final String? errorMessage;
  final List<Timeoff>? timeoffs;
  final Employee? employee;
  const TimeoffState({
    this.isLoading = false,
    this.isFormLoading = false,
    this.isError = false,
    this.isFormError = false,
    this.isSuccess = false,
    this.isFormSuccess = false,
    this.errorMessage,
    this.timeoffs,
    this.employee,
    this.loadMore = false,
  });
  TimeoffState copyWith({
    bool? isLoading,
    bool? isError,
    bool? isSuccess,
    bool? loadMore,
    String? errorMessage,
    List<Timeoff>? timeoffs,
    bool? isFormLoading,
    bool? isFormError,
    Employee? employee,
    bool? isFormSuccess,
  }) {
    return TimeoffState(
      errorMessage: errorMessage ?? this.errorMessage,
      isError: isError ?? this.isError,
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      loadMore: loadMore ?? this.loadMore,
      timeoffs: timeoffs ?? this.timeoffs,
      employee: employee ?? this.employee,
      isFormLoading: isFormLoading ?? this.isFormLoading,
      isFormError: isFormError ?? this.isFormError,
      isFormSuccess: isFormSuccess ?? this.isFormSuccess,
    );
  }

  @override
  List<Object?> get props => [
        errorMessage,
        isLoading,
        isError,
        isSuccess,
        loadMore,
        timeoffs,
        isFormLoading,
        isFormError,
        isFormSuccess,
        employee,
      ];
}
