import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'academy_event.dart';
part 'academy_state.dart';

class AcademyBloc extends Bloc<AcademyEvent, AcademyState> {
  AcademyBloc() : super(const AcademyState()) {
    on<AcademyEvent>((event, emit) {});
  }
}
