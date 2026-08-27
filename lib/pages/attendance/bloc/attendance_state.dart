part of 'attendance_bloc.dart';

final class AttendanceState extends Equatable {
  final bool isLoading, isError, isSuccess, historyLoading, loadMore;
  final bool cutoffLoading, cutoffError;
  final bool summaryLoading, summaryError;
  final String? errorMessage;
  final Shift? shift;
  final Position? position;
  final Pagination? serverside;
  final List<Attendance>? histories;
  final List<AttendanceLog>? logs;
  final Cutoff? cutoff;
  final AttendanceSummary? attendanceSummary;
  const AttendanceState({
    this.isLoading = false,
    this.historyLoading = false,
    this.isError = false,
    this.isSuccess = false,
    this.errorMessage,
    this.shift,
    this.position,
    this.serverside,
    this.histories,
    this.logs,
    this.loadMore = false,
    this.cutoffLoading = false,
    this.cutoffError = false,
    this.cutoff,
    this.summaryLoading = false,
    this.summaryError = false,
    this.attendanceSummary,
  });
  AttendanceState copyWith({
    bool? isLoading,
    bool? historyLoading,
    bool? isError,
    bool? isSuccess,
    String? errorMessage,
    LiveAttendanceSchedule? schedule,
    Position? position,
    List<Attendance>? histories,
    List<AttendanceLog>? logs,
    Shift? shift,
    Pagination? serverside,
    bool? loadMore,
    bool? cutoffLoading,
    bool? cutoffError,
    Cutoff? cutoff,
    bool? summaryLoading,
    bool? summaryError,
    AttendanceSummary? attendanceSummary,
  }) {
    return AttendanceState(
      errorMessage: errorMessage ?? this.errorMessage,
      isError: isError ?? this.isError,
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      position: position ?? this.position,
      histories: histories ?? this.histories,
      historyLoading: historyLoading ?? this.historyLoading,
      logs: logs ?? this.logs,
      shift: shift ?? this.shift,
      serverside: serverside ?? this.serverside,
      loadMore: loadMore ?? this.loadMore,
      cutoffLoading: cutoffLoading ?? this.cutoffLoading,
      cutoffError: cutoffError ?? this.cutoffError,
      cutoff: cutoff ?? this.cutoff,
      summaryLoading: summaryLoading ?? this.summaryLoading,
      summaryError: summaryError ?? this.summaryError,
      attendanceSummary: attendanceSummary ?? this.attendanceSummary,
    );
  }

  @override
  List<Object?> get props => [
        errorMessage,
        isLoading,
        isError,
        isSuccess,
        position,
        histories,
        historyLoading,
        logs,
        shift,
        serverside,
        loadMore,
        cutoffLoading,
        cutoffError,
        cutoff,
        summaryLoading,
        summaryError,
        attendanceSummary,
      ];
}
