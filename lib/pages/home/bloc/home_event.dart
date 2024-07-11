part of 'home_bloc.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();
}

class OnGetSchoolCalendar extends HomeEvent {
  const OnGetSchoolCalendar();
  @override
  List<Object?> get props => [];
}
