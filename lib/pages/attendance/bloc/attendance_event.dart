part of 'attendance_bloc.dart';

abstract class AttendanceEvent extends Equatable {
  const AttendanceEvent();
}

class OnInit extends AttendanceEvent {
  const OnInit();
  @override
  List<Object?> get props => [];
}

class OnGetHistory extends AttendanceEvent {
  final Map<String, dynamic> map;
  const OnGetHistory(this.map);
  @override
  List<Object?> get props => [];
}

class OnGetCurrentLog extends AttendanceEvent {
  const OnGetCurrentLog();
  @override
  List<Object?> get props => [];
}

class OnGetAll extends AttendanceEvent {
  final Map<String, dynamic> map;
  const OnGetAll(this.map);
  @override
  List<Object?> get props => [];
}

class OnLoadMore extends AttendanceEvent {
  final Map<String, dynamic> map;
  const OnLoadMore(this.map);
  @override
  List<Object?> get props => [];
}
