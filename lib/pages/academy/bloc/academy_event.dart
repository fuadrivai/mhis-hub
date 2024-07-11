part of 'academy_bloc.dart';

abstract class AcademyEvent extends Equatable {
  const AcademyEvent();
}

class OnInitData extends Equatable {
  const OnInitData();

  @override
  List<Object?> get props => [];
}
