part of 'employee_bloc.dart';

abstract class EmployeeEvent extends Equatable {
  const EmployeeEvent();
}

class OnInit extends EmployeeEvent {
  const OnInit();
  @override
  List<Object?> get props => [];
}

class OnLoadMore extends EmployeeEvent {
  const OnLoadMore();
  @override
  List<Object?> get props => [];
}

class OnSearchChanged extends EmployeeEvent {
  final String email;
  const OnSearchChanged(this.email);
  @override
  List<Object?> get props => [];
}
