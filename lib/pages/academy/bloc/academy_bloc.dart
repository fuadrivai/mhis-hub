import 'package:equatable/equatable.dart';
import 'package:fl_mhis_hr/pages/academy/repository/academy_api.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'academy_event.dart';
part 'academy_state.dart';

class AcademyBloc extends Bloc<AcademyEvent, AcademyState> {
  AcademyBloc() : super(const AcademyState()) {
    on<OnInitData>(_onInitData);
  }

  void _onInitData(OnInitData event, Emitter<AcademyState> emit) async {
    try {
      emit(state.copyWith(isLoading: true));
      String email = event.email;
      var res = await AcademyApi.academyLogin(email);
      print(res);

      emit(state.copyWith(isLoading: false));
    } catch (e) {
      print(e);
    }
  }
}
