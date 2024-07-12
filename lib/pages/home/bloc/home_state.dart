part of 'home_bloc.dart';

final class HomeState extends Equatable {
  const HomeState({
    this.schedules,
    this.scheduleLoading = true,
    this.newsletterLoading = true,
    this.newsletters,
    this.scheduleError = false,
    this.scheduleErrorMessage,
  });
  final List<Schedule>? schedules;
  final List<Newsletter>? newsletters;
  final String? scheduleErrorMessage;
  final bool scheduleLoading;
  final bool newsletterLoading;
  final bool scheduleError;

  HomeState copyWith({
    List<Schedule>? schedules,
    List<Newsletter>? newsletters,
    bool? scheduleLoading,
    bool? newsletterLoading,
    bool? scheduleError,
    String? scheduleErrorMessage,
  }) {
    return HomeState(
      schedules: schedules ?? this.schedules ?? [],
      scheduleLoading: scheduleLoading ?? this.scheduleLoading,
      newsletterLoading: newsletterLoading ?? this.newsletterLoading,
      newsletters: newsletters ?? this.newsletters,
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
        newsletters,
        newsletterLoading,
      ];
}
