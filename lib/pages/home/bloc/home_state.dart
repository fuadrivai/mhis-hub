part of 'home_bloc.dart';

final class HomeState extends Equatable {
  const HomeState({
    this.calendarSchool,
    this.calendarErrorMessage,
    this.calendarError = false,
    this.calendarLoading = true,
    this.attendanceLoading = true,
    this.attendanceError = false,
    this.attendanceErrorMessage,
    this.attendaceSchedule,
    this.newsletters,
    this.newsletterLoading = true,
    this.newsletterError = false,
    this.newsletterErrorMessage,
  });

  final bool attendanceLoading;
  final bool attendanceError;
  final String? attendanceErrorMessage;
  final LiveAttendanceSchedule? attendaceSchedule;

  final bool calendarLoading;
  final bool calendarError;
  final String? calendarErrorMessage;
  final List<SchoolCalendar>? calendarSchool;

  final bool newsletterLoading;
  final bool newsletterError;
  final String? newsletterErrorMessage;
  final List<Newsletter>? newsletters;

  HomeState copyWith({
    bool? attendanceLoading,
    bool? attendanceError,
    String? attendanceErrorMessage,
    LiveAttendanceSchedule? attendaceSchedule,
    bool? calendarLoading,
    bool? calendarError,
    String? calendarErrorMessage,
    List<SchoolCalendar>? calendarSchool,
    bool? newsletterLoading,
    bool? newsletterError,
    String? newsletterErrorMessage,
    List<Newsletter>? newsletters,
  }) {
    return HomeState(
      attendanceLoading: attendanceLoading ?? this.attendanceLoading,
      attendanceError: attendanceError ?? this.attendanceError,
      attendanceErrorMessage:
          attendanceErrorMessage ?? this.attendanceErrorMessage,
      attendaceSchedule: attendaceSchedule ?? this.attendaceSchedule,
      calendarLoading: calendarLoading ?? this.calendarLoading,
      calendarError: calendarError ?? this.calendarError,
      calendarErrorMessage: calendarErrorMessage ?? this.calendarErrorMessage,
      calendarSchool: calendarSchool ?? this.calendarSchool,
      newsletterLoading: newsletterLoading ?? this.newsletterLoading,
      newsletterError: newsletterError ?? this.newsletterError,
      newsletterErrorMessage:
          newsletterErrorMessage ?? this.newsletterErrorMessage,
      newsletters: newsletters ?? this.newsletters,
    );
  }

  @override
  List<Object?> get props => [
        attendanceLoading,
        attendanceError,
        attendanceErrorMessage,
        attendaceSchedule,
        calendarLoading,
        calendarError,
        calendarErrorMessage,
        calendarSchool,
        newsletterLoading,
        newsletterError,
        newsletterErrorMessage,
        newsletters,
      ];
}
