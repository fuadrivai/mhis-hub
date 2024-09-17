part of 'attendance_bloc.dart';

final class AttendanceState extends Equatable {
  final bool isLoading, isError, isSuccess, historyLoading;
  final String? errorMessage;
  final LiveAttendanceSchedule? schedule;
  final Position? position;
  final List<AttendanceHistory>? history;
  const AttendanceState({
    this.isLoading = false,
    this.historyLoading = false,
    this.isError = false,
    this.isSuccess = false,
    this.errorMessage,
    this.schedule,
    this.position,
    this.history,
  });
  AttendanceState copyWith({
    bool? isLoading,
    bool? historyLoading,
    bool? isError,
    bool? isSuccess,
    String? errorMessage,
    LiveAttendanceSchedule? schedule,
    Position? position,
    List<AttendanceHistory>? history,
  }) {
    return AttendanceState(
      errorMessage: errorMessage ?? this.errorMessage,
      isError: isError ?? this.isError,
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      position: position ?? this.position,
      schedule: schedule ?? this.schedule,
      history: history ?? this.history,
      historyLoading: historyLoading ?? this.historyLoading,
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
        history,
        historyLoading,
      ];
}
