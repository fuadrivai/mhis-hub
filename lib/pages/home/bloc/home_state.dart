part of 'home_bloc.dart';

final class HomeState extends Equatable {
  const HomeState({
    this.schedules,
    this.scheduleLoading = true,
    this.scheduleError = false,
    this.scheduleErrorMessage,
    this.newsletters,
    this.newsletterLoading = true,
    this.newsletterError = false,
    this.newsletterErrorMessage,
  });
  final List<Schedule>? schedules;
  final String? scheduleErrorMessage;
  final bool scheduleLoading;
  final bool scheduleError;
  final bool newsletterLoading;
  final bool newsletterError;
  final String? newsletterErrorMessage;
  final List<Newsletter>? newsletters;

  HomeState copyWith(
      {List<Schedule>? schedules,
      bool? scheduleLoading,
      bool? scheduleError,
      String? scheduleErrorMessage,
      bool? newsletterLoading,
      List<Newsletter>? newsletters,
      String? newsletterErrorMessage,
      bool? newsletterError}) {
    return HomeState(
      schedules: schedules ?? this.schedules ?? [],
      scheduleLoading: scheduleLoading ?? this.scheduleLoading,
      scheduleError: scheduleError ?? this.scheduleError,
      scheduleErrorMessage: scheduleErrorMessage ?? this.scheduleErrorMessage,
      newsletterLoading: newsletterLoading ?? this.newsletterLoading,
      newsletters: newsletters ?? this.newsletters,
      newsletterErrorMessage:
          newsletterErrorMessage ?? this.newsletterErrorMessage,
      newsletterError: newsletterError ?? this.newsletterError,
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
        newsletterError,
        newsletterErrorMessage,
      ];
}
