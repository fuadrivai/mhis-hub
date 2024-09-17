part of 'home_bloc.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();
}

class OnInitAttendance extends HomeEvent {
  const OnInitAttendance();
  @override
  List<Object?> get props => [];
}

class OnInitCalendar extends HomeEvent {
  const OnInitCalendar();
  @override
  List<Object?> get props => [];
}

class OnGetNewsletter extends HomeEvent {
  const OnGetNewsletter();
  @override
  List<Object?> get props => [];
}

class OnGetPayslip extends HomeEvent {
  const OnGetPayslip();
  @override
  List<Object?> get props => [];
}
