part of 'timeoff_bloc.dart';

abstract class TimeoffEvent extends Equatable {
  const TimeoffEvent();
}

class OnInit extends TimeoffEvent {
  const OnInit();
  @override
  List<Object?> get props => [];
}

class OnInitForm extends TimeoffEvent {
  const OnInitForm();
  @override
  List<Object?> get props => [];
}
