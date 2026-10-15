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
    this.shift,
    this.newsletters,
    this.newsletterLoading = true,
    this.newsletterError = false,
    this.newsletterErrorMessage,
    this.sops,
    this.sopLoading = true,
    this.sopError = false,
    this.sopErrorMessage,
    this.announcements,
    this.announcementLoading = true,
    this.announcementError = false,
    this.announcementErrorMessage,
  });

  final bool attendanceLoading;
  final bool attendanceError;
  final String? attendanceErrorMessage;
  final Shift? shift;

  final bool calendarLoading;
  final bool calendarError;
  final String? calendarErrorMessage;
  final List<SchoolCalendar>? calendarSchool;

  final bool newsletterLoading;
  final bool newsletterError;
  final String? newsletterErrorMessage;
  final List<Newsletter>? newsletters;

  final bool sopLoading;
  final bool sopError;
  final String? sopErrorMessage;
  final List<Sop>? sops;

  final bool announcementLoading;
  final bool announcementError;
  final String? announcementErrorMessage;
  final List<Announcement>? announcements;

  HomeState copyWith({
    bool? attendanceLoading,
    bool? attendanceError,
    String? attendanceErrorMessage,
    Shift? shift,
    bool? calendarLoading,
    bool? calendarError,
    String? calendarErrorMessage,
    List<SchoolCalendar>? calendarSchool,
    bool? newsletterLoading,
    bool? newsletterError,
    String? newsletterErrorMessage,
    List<Newsletter>? newsletters,
    bool? sopLoading,
    bool? sopError,
    String? sopErrorMessage,
    List<Sop>? sops,
    bool? announcementLoading,
    bool? announcementError,
    String? announcementErrorMessage,
    List<Announcement>? announcements,
  }) {
    return HomeState(
        attendanceLoading: attendanceLoading ?? this.attendanceLoading,
        attendanceError: attendanceError ?? this.attendanceError,
        attendanceErrorMessage:
            attendanceErrorMessage ?? this.attendanceErrorMessage,
        shift: shift ?? this.shift,
        calendarLoading: calendarLoading ?? this.calendarLoading,
        calendarError: calendarError ?? this.calendarError,
        calendarErrorMessage: calendarErrorMessage ?? this.calendarErrorMessage,
        calendarSchool: calendarSchool ?? this.calendarSchool,
        newsletterLoading: newsletterLoading ?? this.newsletterLoading,
        newsletterError: newsletterError ?? this.newsletterError,
        newsletterErrorMessage:
            newsletterErrorMessage ?? this.newsletterErrorMessage,
        newsletters: newsletters ?? this.newsletters,
        sopLoading: sopLoading ?? this.sopLoading,
        sopError: sopError ?? this.sopError,
        sopErrorMessage: sopErrorMessage ?? this.sopErrorMessage,
        sops: sops ?? this.sops,
        announcementLoading: announcementLoading ?? this.announcementLoading,
        announcementError: announcementError ?? this.announcementError,
        announcementErrorMessage:
            announcementErrorMessage ?? this.announcementErrorMessage,
        announcements: announcements ?? this.announcements);
  }

  @override
  List<Object?> get props => [
        attendanceLoading,
        attendanceError,
        attendanceErrorMessage,
        shift,
        calendarLoading,
        calendarError,
        calendarErrorMessage,
        calendarSchool,
        newsletterLoading,
        newsletterError,
        newsletterErrorMessage,
        newsletters,
        sopLoading,
        sopError,
        sopErrorMessage,
        sops,
        announcementLoading,
        announcementError,
        announcementErrorMessage,
        announcements,
      ];
}
