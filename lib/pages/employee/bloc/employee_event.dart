part of 'employee_bloc.dart';

abstract class EmployeeEvent extends Equatable {
  const EmployeeEvent();
}

class OnInit extends EmployeeEvent {
  const OnInit();
  @override
  List<Object?> get props => [];
}

class OnInitV2 extends EmployeeEvent {
  final Map<String, dynamic> map;
  const OnInitV2(this.map);
  @override
  List<Object?> get props => [];
}

class OnLoadMore extends EmployeeEvent {
  final Map<String, dynamic> map;
  const OnLoadMore(this.map);
  @override
  List<Object?> get props => [];
}

class OnSearchChanged extends EmployeeEvent {
  final Map<String, dynamic> map;
  const OnSearchChanged(this.map);
  @override
  List<Object?> get props => [];
}
