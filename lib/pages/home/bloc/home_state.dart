part of 'home_bloc.dart';

final class HomeState extends Equatable {
  const HomeState({
    this.schedules,
    this.scheduleLoading = true,
    this.scheduleError = false,
    this.scheduleErrorMessage,
  });
  final List<Schedule>? schedules;
  final String? scheduleErrorMessage;
  final bool scheduleLoading;
  final bool scheduleError;

  HomeState copyWith({
    List<Schedule>? schedules,
    bool? scheduleLoading,
    bool? scheduleError,
    String? scheduleErrorMessage,
  }) {
    return HomeState(
      schedules: schedules ?? this.schedules ?? [],
      scheduleLoading: scheduleLoading ?? this.scheduleLoading,
      scheduleError: scheduleError ?? this.scheduleError,
      scheduleErrorMessage: scheduleErrorMessage ?? this.scheduleErrorMessage,
    );
  }

  @override
  List<Object?> get props => [
        schedules,
        scheduleLoading,
        scheduleError,
        scheduleErrorMessage,
      ];
}
