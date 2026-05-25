part of 'attendance_bloc.dart';

final class AttendanceState extends Equatable {
  final bool isLoading, isError, isSuccess, historyLoading;
  final String? errorMessage;
  final LiveAttendanceSchedule? schedule;
  final Position? position;
  final List<Attendance>? histories;
  final List<AttendanceLog>? logs;
  const AttendanceState({
    this.isLoading = false,
    this.historyLoading = false,
    this.isError = false,
    this.isSuccess = false,
    this.errorMessage,
    this.schedule,
    this.position,
    this.histories,
    this.logs,
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
  }) {
    return AttendanceState(
      errorMessage: errorMessage ?? this.errorMessage,
      isError: isError ?? this.isError,
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      position: position ?? this.position,
      schedule: schedule ?? this.schedule,
      histories: histories ?? this.histories,
      historyLoading: historyLoading ?? this.historyLoading,
      logs: logs ?? this.logs,
    );
  }

  @override
  List<Object?> get props => [
        errorMessage,
        isLoading,
        isError,
        isSuccess,
        position,
        schedule,
        histories,
        historyLoading,
        logs,
      ];
}
