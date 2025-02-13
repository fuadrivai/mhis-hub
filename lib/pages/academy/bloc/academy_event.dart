part of 'academy_bloc.dart';

abstract class AcademyEvent extends Equatable {
  const AcademyEvent();
}

class OnInitData extends AcademyEvent {
  final String email;
  const OnInitData(this.email);

  @override
  List<Object?> get props => [];
}
