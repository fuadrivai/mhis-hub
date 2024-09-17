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
